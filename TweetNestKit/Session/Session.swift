//
//  Session.swift
//  TweetNestKit
//
//  Created by Jaehong Kang on 2021/02/23.
//

import Foundation
import CoreData
import OrderedCollections
import UnifiedLogging
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
    public private(set) lazy var backgroundTaskScheduler = BackgroundTaskScheduler(session: self)
    private(set) lazy var dataAssetsURLSessionManager = DataAssetsURLSessionManager(session: self)

    private lazy var persistentStoreRemoteChangeNotification = NotificationCenter.default
        .publisher(for: .NSPersistentStoreRemoteChange, object: persistentContainer.persistentStoreCoordinator)
        .sink { [weak self] _ in
            self?.handlePersistentStoreRemoteChanges()
        }

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
        }
    }

    deinit {
        Task {
            await backgroundTaskScheduler.invalidate()
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
        try await sessionActor.twitterSession(for: accountObjectID)
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
