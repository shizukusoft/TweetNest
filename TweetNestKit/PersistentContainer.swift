//
//  PersistentContainer.swift
//  TweetNestKit
//
//  Created by Jaehong Kang on 2021/02/24.
//

import CloudKit
import CoreData
import OrderedCollections
import BackgroundTask
import UnifiedLogging

public enum PersistentContainerError: Error {
    case persistentStoresLoadingFailure([NSPersistentStoreDescription: Error])
}

public class PersistentContainer: NSPersistentCloudKitContainer {
    public override class func defaultDirectoryURL() -> URL {
        Session.containerApplicationSupportURL
    }

    public override var viewContext: NSManagedObjectContext {
        let viewContext = super.viewContext
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyStoreTrumpMergePolicyType)
        return viewContext
    }

    #if canImport(CoreSpotlight)
    var usersSpotlightDelegate: UsersSpotlightDelegate?
    #endif

    init(inMemory: Bool = false) {
        super.init(name: Bundle.tweetNestKit.name!, managedObjectModel: Self.managedObjectModel)

        if inMemory == false {
            let accountsPersistentStoreDescription = NSPersistentStoreDescription(url: Self.accountsPersistentStoreURL)
            accountsPersistentStoreDescription.type = NSSQLiteStoreType
            accountsPersistentStoreDescription.configuration = Self.accountsPersistentStoreConfiguration
            accountsPersistentStoreDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: Session.accountsCloudKitIdentifier)
            accountsPersistentStoreDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            accountsPersistentStoreDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

            let tweetNestKitPersistentStoreDescription = NSPersistentStoreDescription(url: Self.defaultPersistentStoreURL)
            tweetNestKitPersistentStoreDescription.type = NSSQLiteStoreType
            tweetNestKitPersistentStoreDescription.configuration = Self.defaultPersistentStoreConfiguration
            tweetNestKitPersistentStoreDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: Session.cloudKitIdentifier)
            tweetNestKitPersistentStoreDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            tweetNestKitPersistentStoreDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

            let dataAssetsPersistentStoreDescription = NSPersistentStoreDescription(url: Self.dataAssetsPersistentStoreURL)
            dataAssetsPersistentStoreDescription.type = NSSQLiteStoreType
            dataAssetsPersistentStoreDescription.configuration = Self.dataAssetsPersistentStoreConfiguration
            dataAssetsPersistentStoreDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: Session.dataAssetsCloudKitIdentifier)
            dataAssetsPersistentStoreDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            dataAssetsPersistentStoreDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

            persistentStoreDescriptions = [
                accountsPersistentStoreDescription,
                tweetNestKitPersistentStoreDescription,
                dataAssetsPersistentStoreDescription,
            ]

            #if canImport(CoreSpotlight)
            self.usersSpotlightDelegate = UsersSpotlightDelegate(forStoreWith: tweetNestKitPersistentStoreDescription, coordinator: self.persistentStoreCoordinator)
            #endif
        } else {
            persistentStoreDescriptions.forEach {
                $0.url = nil
                $0.type = NSInMemoryStoreType
                $0.cloudKitContainerOptions = nil
            }
        }
    }

    public override func loadPersistentStores(completionHandler block: @escaping (NSPersistentStoreDescription, Error?) -> Void) {
        persistentStoreCoordinator.perform {
            do {
                try self.migrationIfNeeded()

                let dispatchGroup = DispatchGroup()
                for _ in self.persistentStoreDescriptions.indices {
                    dispatchGroup.enter()
                }

                dispatchGroup.notify(queue: .global(qos: .default)) {
                    #if canImport(CoreSpotlight)
                    self.persistentStoreCoordinator.perform {
                        if let usersSpotlightDelegate = self.usersSpotlightDelegate {
                            usersSpotlightDelegate.startSpotlightIndexing()
                        }
                    }
                    #endif

                    #if DEBUG
                    try! self.initializeCloudKitSchema(options: [])
                    #endif
                }

                super.loadPersistentStores { storeDescription, error in
                    dispatchGroup.leave()

                    block(storeDescription, error)
                }
            } catch {
                self.persistentStoreDescriptions.forEach {
                    block($0, error)
                }
            }
        }
    }

    public override func newBackgroundContext() -> NSManagedObjectContext {
        let backgroundContext = super.newBackgroundContext()
        backgroundContext.automaticallyMergesChangesFromParent = true
        backgroundContext.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyStoreTrumpMergePolicyType)
        return backgroundContext
    }
}

extension PersistentContainer {
    public func loadPersistentStores() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            var loadedPersistentStores = [NSPersistentStoreDescription: Error?]()

            self.loadPersistentStores { (storeDescription, error) in
                loadedPersistentStores[storeDescription] = error

                if loadedPersistentStores.count == self.persistentStoreDescriptions.count {
                    let errors = loadedPersistentStores.compactMapValues { $0 }

                    guard errors.isEmpty else {
                        continuation.resume(throwing: PersistentContainerError.persistentStoresLoadingFailure(errors))
                        return
                    }

                    continuation.resume()
                }
            }
        }
    }
}

extension PersistentContainer {
    private func migrationIfNeeded() throws {
        guard FileManager.default.fileExists(atPath: Self.defaultPersistentStoreURL.path) else {
            return
        }

        try withExtendedBackgroundExecution {
            var isMigrated: Bool = false

            if FileManager.default.fileExists(atPath: Self.dataAssetsPersistentStoreURL.path) == false {
                // Step 1. Migrate default store with nil configuration

                let defaultModelMigrationPersistentContainer = NSPersistentContainer(name: "TweetNestKit", managedObjectModel: persistentStoreCoordinator.managedObjectModel)
                defaultModelMigrationPersistentContainer.persistentStoreDescriptions[0].type = NSSQLiteStoreType
                defaultModelMigrationPersistentContainer.persistentStoreDescriptions[0].url = Self.defaultPersistentStoreURL
                defaultModelMigrationPersistentContainer.persistentStoreDescriptions[0].setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)

                defaultModelMigrationPersistentContainer.loadPersistentStores { _, _ in }

                // Step 2. Migrate default store to data assets store

                let dataAssetsStoreMigrationPersistentContainer = NSPersistentContainer(name: "DataAssets", managedObjectModel: persistentStoreCoordinator.managedObjectModel)
                dataAssetsStoreMigrationPersistentContainer.persistentStoreDescriptions[0].type = NSSQLiteStoreType
                dataAssetsStoreMigrationPersistentContainer.persistentStoreDescriptions[0].configuration = Self.dataAssetsPersistentStoreConfiguration
                dataAssetsStoreMigrationPersistentContainer.persistentStoreDescriptions[0].url = Self.defaultPersistentStoreURL
                dataAssetsStoreMigrationPersistentContainer.persistentStoreDescriptions[0].setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
                dataAssetsStoreMigrationPersistentContainer.persistentStoreDescriptions[0].setOption(true as NSNumber, forKey: NSReadOnlyPersistentStoreOption)

                dataAssetsStoreMigrationPersistentContainer.loadPersistentStores { _, _ in }

                if let store = dataAssetsStoreMigrationPersistentContainer.persistentStoreCoordinator.persistentStores.first {
                    _ = try dataAssetsStoreMigrationPersistentContainer.persistentStoreCoordinator.migratePersistentStore(store, to: Self.dataAssetsPersistentStoreURL, options: nil, type: .sqlite)
                }

                isMigrated = true
            }

            if isMigrated { // Clean up default store
                // Step 1. Migrate default store to temp store, and migrate back to default store

                let defaultStoreMigrationPersistentContainer = NSPersistentContainer(name: "TweetNestKit", managedObjectModel: persistentStoreCoordinator.managedObjectModel)
                defaultStoreMigrationPersistentContainer.persistentStoreDescriptions[0].type = NSSQLiteStoreType
                defaultStoreMigrationPersistentContainer.persistentStoreDescriptions[0].configuration = Self.defaultPersistentStoreConfiguration
                defaultStoreMigrationPersistentContainer.persistentStoreDescriptions[0].url = Self.defaultPersistentStoreURL
                defaultStoreMigrationPersistentContainer.persistentStoreDescriptions[0].setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
                defaultStoreMigrationPersistentContainer.persistentStoreDescriptions[0].setOption(true as NSNumber, forKey: NSReadOnlyPersistentStoreOption)

                defaultStoreMigrationPersistentContainer.loadPersistentStores { _, _ in }

                if let store = defaultStoreMigrationPersistentContainer.persistentStoreCoordinator.persistentStores.first {
                    let tempStore = try defaultStoreMigrationPersistentContainer.persistentStoreCoordinator.migratePersistentStore(store, to: Self.defaultPersistentStoreURL.appendingPathExtension("temp"), options: nil, type: .sqlite)
                    try defaultStoreMigrationPersistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: Self.defaultPersistentStoreURL, type: .sqlite, options: nil)

                    _ = try defaultStoreMigrationPersistentContainer.persistentStoreCoordinator.migratePersistentStore(tempStore, to: Self.defaultPersistentStoreURL, options: nil, type: .sqlite)
                    try defaultStoreMigrationPersistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: Self.defaultPersistentStoreURL.appendingPathExtension("temp"), type: .sqlite, options: nil)
                }
            }

            // TODO: Remove orphaned CloudKit records (e.g. DataAssets from main container)
        }
    }
}

extension PersistentContainer {
    public struct CloudKitEvent {
        public enum EventType {
            case setup
            case `import`
            case export
            case unknown(Int)
        }

        public var identifier: UUID
        public var storeIdentifier: String
        public var type: EventType
        public var startDate: Date
        public var endDate: Date?
        public var result: Result<Void, Error>?
    }
}

extension PersistentContainer.CloudKitEvent.EventType {
    init(_ eventType: NSPersistentCloudKitContainer.EventType) {
        switch eventType {
        case .setup:
            self = .setup
        case .import:
            self = .import
        case .export:
            self = .export
        @unknown default:
            self = .unknown(eventType.rawValue)
        }
    }
}

extension PersistentContainer.CloudKitEvent.EventType: Equatable { }

extension PersistentContainer.CloudKitEvent {
    init(_ event: NSPersistentCloudKitContainer.Event) {
        self.identifier = event.identifier
        self.storeIdentifier = event.storeIdentifier
        self.type = EventType(event.type)
        self.startDate = event.startDate
        self.endDate = event.endDate

        if let error = event.error {
            result = .failure(error)
        } else if event.succeeded {
            result = .success(())
        } else {
            result = nil
        }
    }
}

extension PersistentContainer.CloudKitEvent: Equatable {
    public static func == (lhs: PersistentContainer.CloudKitEvent, rhs: PersistentContainer.CloudKitEvent) -> Bool {
        lhs.identifier == rhs.identifier &&
        lhs.storeIdentifier == rhs.storeIdentifier &&
        lhs.type == rhs.type &&
        lhs.startDate == rhs.startDate &&
        lhs.endDate == rhs.endDate &&
        { () -> Bool in
            switch (lhs.result, rhs.result) {
            case (.success, .success):
                return true
            case (.failure, .failure):
                return true
            case (nil, nil):
                return true
            default:
                return false
            }
        }()
    }
}
