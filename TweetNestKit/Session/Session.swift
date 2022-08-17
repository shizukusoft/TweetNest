//
//  Session.swift
//  TweetNestKit
//
//  Created by Jaehong Kang on 2021/02/23.
//

import Foundation
import UserNotifications
import CoreData
import OrderedCollections
import UnifiedLogging
import BackgroundTask
import Twitter

public final class Session {
    public static let shared = Session(twitterAPIConfiguration: { nil }, inMemory: false)

    private let _twitterAPIConfiguration: AsyncLazy<TwitterAPIConfiguration>
    public var twitterAPIConfiguration: TwitterAPIConfiguration {
        get async throws {
            try await _twitterAPIConfiguration.wrappedValue
        }
    }

    var isShared: Bool {
        self === Self.shared
    }

    let logger = Logger(label: Bundle.tweetNestKit.bundleIdentifier!, category: String(reflecting: Session.self))
    let sessionActor = SessionActor()
    public let persistentContainer: PersistentContainer
    private(set) lazy var userDataAssetsURLSessionManager = UserDataAssetsURLSessionManager(session: self)
    private(set) lazy var userNotificationManager = UserNotificationManager(session: self)

    private lazy var persistentStoreRemoteChangeNotificationContext: NSManagedObjectContext = persistentContainer.newBackgroundContext()
    private lazy var persistentStoreRemoteChangeNotification = NotificationCenter.default
        .publisher(for: .NSPersistentStoreRemoteChange, object: persistentContainer.persistentStoreCoordinator)
        .map { $0.userInfo?[NSPersistentHistoryTokenKey] as? NSPersistentHistoryToken }
        .removeDuplicates()
        .sink { [weak self] persistentHistoryToken in
            guard let self = self else { return }

            Task {
                await self.handlePersistentStoreRemoteChanges(persistentHistoryToken, context: self.persistentStoreRemoteChangeNotificationContext)
            }
        }

    @MainActor @Published
    public private(set) var persistentContainerLoadingResult: Result<Void, Swift.Error>?

    private lazy var fetchNewDataIntervalObserver = TweetNestKitUserDefaults.standard
        .observe(\.fetchNewDataInterval, options: [.new]) { [weak self] userDefaults, changes in
            self?.fetchNewDataIntervalDidChange(changes.newValue ?? userDefaults.fetchNewDataInterval)
        }

    private init(twitterAPIConfiguration: @escaping () async throws -> TwitterAPIConfiguration?, inMemory: Bool) {
        _twitterAPIConfiguration = .init({
            if let twitterAPIConfiguration = try await twitterAPIConfiguration() {
                return twitterAPIConfiguration
            } else {
                return try await .cloudKit
            }
        })
        self.persistentContainer = PersistentContainer(inMemory: inMemory)

        _ = self.persistentStoreRemoteChangeNotification
        _ = self.fetchNewDataIntervalObserver

        self.persistentContainer.persistentStoreCoordinator.perform { [logger] in
            self.persistentContainer.loadPersistentStores { result in
                switch result {
                case .success:
                    Task.detached(priority: .utility) {
                        _ = try? await self.twitterAPIConfiguration
                        _ = self.userDataAssetsURLSessionManager
                        _ = self.userNotificationManager

                        #if DEBUG
                        guard self.persistentContainer.persistentStoreDescriptions.contains(where: { $0.cloudKitContainerOptions != nil }) else {
                            return
                        }

                        do {
                            try self.persistentContainer.initializeCloudKitSchema(options: [])
                        } catch {
                            logger.error("\(error as NSError, privacy: .public)")
                        }
                        #endif
                    }

                    Task {
                        await MainActor.run {
                            self.persistentContainerLoadingResult = .success(())
                        }
                    }
                case .failure(let error):
                    logger.error("Error occurred while load persistent stores: \(error as NSError, privacy: .public)")

                    Task {
                        await MainActor.run {
                            self.persistentContainerLoadingResult = .failure(error)
                        }
                    }
                }
            }
        }
    }

    deinit {
        userDataAssetsURLSessionManager.invalidate()
    }
}

extension Session {
    public convenience init(twitterAPIConfiguration: @autoclosure @escaping () throws -> TwitterAPIConfiguration? = nil, inMemory: Bool = false) {
        self.init(twitterAPIConfiguration: { try twitterAPIConfiguration() }, inMemory: inMemory)
    }

    public convenience init(twitterAPIConfiguration: @autoclosure @escaping () async throws -> TwitterAPIConfiguration? = nil, inMemory: Bool = false) async {
        self.init(twitterAPIConfiguration: twitterAPIConfiguration, inMemory: inMemory)
    }
}

extension Session {
    public func twitterSession(for accountObjectID: NSManagedObjectID? = nil) async throws -> Twitter.Session {
        let twitterAPIConfiguration = try await twitterAPIConfiguration

        guard let accountObjectID = accountObjectID, accountObjectID.isTemporaryID == false else {
            return Twitter.Session(twitterAPIConfiguration: twitterAPIConfiguration)
        }

        return try await sessionActor.run { sessionActor in
            guard let twitterSession = sessionActor.twitterSession(for: accountObjectID.uriRepresentation()) else {
                let twitterSession = Twitter.Session(twitterAPIConfiguration: twitterAPIConfiguration)

                if accountObjectID.isTemporaryID == false {
                    sessionActor.updateTwitterSession(twitterSession, for: accountObjectID.uriRepresentation())
                }

                try await twitterSession.updateCredential(credential(for: accountObjectID))

                return twitterSession
            }

            return twitterSession
        }
    }
}

extension Session {
    @discardableResult
    public static func handleEventsForBackgroundURLSession(_ identifier: String, completionHandler: @escaping () -> Void) -> Bool {
        switch identifier {
        case UserDataAssetsURLSessionManager.backgroundURLSessionIdentifier:
            Task {
                await Session.shared.userDataAssetsURLSessionManager.handleBackgroundURLSessionEvents(completionHandler: completionHandler)
            }
            return true
        default:
            return false
        }
    }
}

extension Session {
    private func fetchNewDataIntervalDidChange(_ newValue: TimeInterval) {
        Task {
            await sessionActor.updateFetchNewDataTimer(interval: newValue, session: self)
        }
    }

    public func pauseBackgroundTaskTimers() {
        Task {
            await sessionActor.destroyFetchNewDataTimer()
            await sessionActor.destroyDataCleansingTimer()
        }
    }

    public func resumeBackgroundTaskTimers() {
        Task {
            await sessionActor.initializeFetchNewDataTimer(interval: TweetNestKitUserDefaults.standard.fetchNewDataInterval, session: self)
            await sessionActor.initializeDataCleansingTimer(interval: Self.cleansingDataInterval, session: self)
        }
    }
}

extension Session {
    private func errorNotificationRequest(_ error: Error, for accountObjectID: NSManagedObjectID? = nil) -> UNNotificationRequest {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = String(localized: "Fetch New Data Error", bundle: .tweetNestKit, comment: "fetch-new-data-error notification title.")
        notificationContent.interruptionLevel = .active
        notificationContent.sound = .default

        if
            let localizedError = error as? LocalizedError,
            let errorDescription = localizedError.errorDescription,
            let failureReason = localizedError.failureReason
        {
            notificationContent.subtitle = errorDescription
            notificationContent.body = failureReason
        } else {
            notificationContent.body = error.localizedDescription
        }

        if let accountObjectID = accountObjectID {
            let context = persistentContainer.newBackgroundContext()

            let persistentID: UUID? = context.performAndWait {
                (context.object(with: accountObjectID) as? ManagedAccount)?.persistentID
            }

            notificationContent.threadIdentifier = persistentID?.uuidString ?? accountObjectID.uriRepresentation().absoluteString
        }

        return UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: nil)
    }

    private func postUserNotification(error: Error, accountObjectID: NSManagedObjectID? = nil) async throws {
        switch error {
        case is CancellationError, URLError.cancelled:
            break
        default:
            let notificationContent = UNMutableNotificationContent()
            notificationContent.title = String(localized: "Fetch New Data Error", bundle: .tweetNestKit, comment: "fetch-new-data-error notification title.")
            notificationContent.interruptionLevel = .active
            notificationContent.sound = .default

            if
                let localizedError = error as? LocalizedError,
                let errorDescription = localizedError.errorDescription,
                let failureReason = localizedError.failureReason
            {
                notificationContent.subtitle = errorDescription
                notificationContent.body = failureReason
            } else {
                notificationContent.body = error.localizedDescription
            }

            if let accountObjectID = accountObjectID {
                let context = persistentContainer.newBackgroundContext()

                let persistentID: UUID? = context.performAndWait {
                    (context.object(with: accountObjectID) as? ManagedAccount)?.persistentID
                }

                notificationContent.threadIdentifier = persistentID?.uuidString ?? accountObjectID.uriRepresentation().absoluteString
            }

            let request = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: nil)
            try await UNUserNotificationCenter.current().add(request)
        }
    }

    @discardableResult
    public func fetchNewData(force: Bool = false) async throws -> Bool {
        guard
            force || TweetNestKitUserDefaults.standard.lastFetchNewDataDate.addingTimeInterval(TweetNestKitUserDefaults.standard.fetchNewDataInterval) < Date()
        else {
            return false
        }

        TweetNestKitUserDefaults.standard.lastFetchNewDataDate = Date()

        let logger = Logger(subsystem: Bundle.tweetNestKit.bundleIdentifier!, category: "fetch-new-data")

        do {
            var hasChanges = false

            for result in try await updateAllAccounts() {
                let accountObjectID = result.0

                do {
                    hasChanges = try hasChanges || result.1.get()
                } catch {
                    logger.error("Error occurred while update account \(accountObjectID, privacy: .public): \(error as NSError, privacy: .public)")

                    try await postUserNotification(error: error, accountObjectID: accountObjectID)
                }
            }

            return hasChanges
        } catch {
            logger.error("Error occurred while update accounts: \(error as NSError, privacy: .public)")

            try await postUserNotification(error: error)

            return false
        }
    }
}
