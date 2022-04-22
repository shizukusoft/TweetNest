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

public class Session {
    public static let shared = Session()

    private let _twitterAPIConfiguration: AsyncLazy<TwitterAPIConfiguration>
    public var twitterAPIConfiguration: TwitterAPIConfiguration {
        get async throws {
            try await _twitterAPIConfiguration.wrappedValue
        }
    }

    private let inMemory: Bool
    private(set) lazy var sessionActor = SessionActor(session: self)

    public private(set) lazy var persistentContainer = PersistentContainer(inMemory: inMemory)
    private(set) lazy var dataAssetsURLSessionManager = DataAssetsURLSessionManager(session: self)

    private lazy var persistentStoreRemoteChangeNotification = NotificationCenter.default
        .publisher(for: .NSPersistentStoreRemoteChange, object: persistentContainer.persistentStoreCoordinator)
        .sink { [weak self] _ in
            self?.handlePersistentStoreRemoteChanges()
        }
    private(set) lazy var persistentStoreRemoteChangeContext: NSManagedObjectContext = {
        let persistentStoreRemoteChangeContext = persistentContainer.newBackgroundContext()
        persistentStoreRemoteChangeContext.undoManager = nil

        return persistentStoreRemoteChangeContext
    }()

    @Published
    public private(set) var persistentContainerLoadingResult: Result<Void, Swift.Error>?

    @Published
    public private(set) var persistentCloudKitContainerEvents: OrderedDictionary<UUID, PersistentContainer.CloudKitEvent> = [:]
    private lazy var persistentCloudKitContainerEventDidChanges = NotificationCenter.default
        .publisher(for: NSPersistentCloudKitContainer.eventChangedNotification, object: persistentContainer)
        .compactMap { $0.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey] as? NSPersistentCloudKitContainer.Event }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] event in
            self?.persistentCloudKitContainerEvents[event.identifier] = PersistentContainer.CloudKitEvent(event)
        }

    private lazy var fetchNewDataIntervalObserver = TweetNestKitUserDefaults.standard
        .observe(\.fetchNewDataInterval, options: [.new]) { [weak self] userDefaults, changes in
            self?.fetchNewDataIntervalDidChange(changes.newValue ?? userDefaults.fetchNewDataInterval)
        }

    private init(twitterAPIConfiguration: @escaping () async throws -> TwitterAPIConfiguration, inMemory: Bool) {
        _twitterAPIConfiguration = .init(twitterAPIConfiguration)
        self.inMemory = inMemory

        Task.detached {
            if inMemory == false {
                _ = self.persistentStoreRemoteChangeNotification
                _ = self.persistentCloudKitContainerEventDidChanges
            }

            Task(priority: .utility) {
                do {
                    try await self.persistentContainer.loadPersistentStores()

                    await MainActor.run {
                        self.persistentContainerLoadingResult = .success(())
                    }
                } catch {
                    Logger(label: Bundle.tweetNestKit.bundleIdentifier!, category: String(reflecting: Self.self))
                        .error("Error occurred while load persistent stores: \(error as NSError, privacy: .public)")

                    await MainActor.run {
                        self.persistentContainerLoadingResult = .failure(error)
                    }
                }
            }

            Task(priority: .utility) {
                _ = try? await self.twitterAPIConfiguration
            }

            Task(priority: .utility) {
                _ = self.fetchNewDataIntervalObserver
            }
        }
    }
}

extension Session {
    public convenience init(twitterAPIConfiguration: @autoclosure @escaping () throws -> TwitterAPIConfiguration? = nil, inMemory: Bool = false) {
        self.init(
            twitterAPIConfiguration: {
                if let twitterAPIConfiguration = try twitterAPIConfiguration() {
                    return twitterAPIConfiguration
                } else {
                    return try await .iCloud
                }
            },
            inMemory: inMemory
        )
    }

    public convenience init(twitterAPIConfiguration: @autoclosure @escaping () async throws -> TwitterAPIConfiguration, inMemory: Bool = false) async {
        self.init(twitterAPIConfiguration: { try await twitterAPIConfiguration() }, inMemory: inMemory)
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
        case DataAssetsURLSessionManager.backgroundURLSessionIdentifier:
            Task {
                await Session.shared.dataAssetsURLSessionManager.handleBackgroundURLSessionEvents(completionHandler: completionHandler)
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
            await sessionActor.updateFetchNewDataTimer(interval: newValue)
        }
    }

    public func pauseAutomaticallyFetchNewData() {
        Task {
            await sessionActor.destroyFetchNewDataTimer()
        }
    }

    public func resumeAutomaticallyFetchNewData() {
        Task {
            await sessionActor.initializeFetchNewDataTimer(interval: TweetNestKitUserDefaults.standard.fetchNewDataInterval)
        }
    }
}

extension Session {
    private func errorNotificationRequest(_ error: Error, for accountObjectID: NSManagedObjectID? = nil) -> UNNotificationRequest {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = String(localized: "Fetch New Data", bundle: .tweetNestKit, comment: "fetch-new-data notification title.")
        notificationContent.subtitle = String(localized: "Error", bundle: .tweetNestKit, comment: "fetch-new-data notification subtitle.")
        notificationContent.body = error.localizedDescription

        switch error {
        case is CancellationError, URLError.cancelled:
            notificationContent.interruptionLevel = .passive
        default:
            notificationContent.sound = .default
        }

        if let accountObjectID = accountObjectID {
            notificationContent.threadIdentifier = persistentContainer.recordID(for: accountObjectID)?.recordName ?? accountObjectID.uriRepresentation().absoluteString
        }

        return UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: nil)
    }

    @discardableResult
    public func fetchNewData(cleansingData: Bool = true, force: Bool = false) async throws -> Bool {
        guard force || TweetNestKitUserDefaults.standard.lastFetchNewDataDate.addingTimeInterval(TweetNestKitUserDefaults.standard.fetchNewDataInterval) < Date() else {
            return false
        }

        TweetNestKitUserDefaults.standard.lastFetchNewDataDate = Date()

        let logger = Logger(subsystem: Bundle.tweetNestKit.bundleIdentifier!, category: "fetch-new-data")

        do {
            defer {
                if cleansingData {
                    Task.detached(priority: .utility) {
                        do {
                            try await self.cleansingAllData(force: force)
                        } catch {
                            logger.error("Error occurred while cleansing data: \(error as NSError, privacy: .public)")
                        }
                    }
                }
            }

            let hasChanges = try await updateAllAccounts()

            return hasChanges.reduce(false) { partialResult, hasChanges in
                let accountObjectID = hasChanges.0

                do {
                    let hasChanges = try hasChanges.1.get()

                    return hasChanges
                } catch {
                    logger.error("Error occurred while update account \(accountObjectID, privacy: .public): \(error as NSError, privacy: .public)")

                    Task.detached {
                        do {
                            try await UNUserNotificationCenter.current().add(self.errorNotificationRequest(error, for: accountObjectID))
                        } catch {
                            logger.error("Error occurred while request notification: \(error as NSError, privacy: .public)")
                        }
                    }

                    return false
                }
            }
        } catch {
            logger.error("Error occurred while update accounts: \(error as NSError, privacy: .public)")

            try await UNUserNotificationCenter.current().add(errorNotificationRequest(error))

            return false
        }
    }
}
