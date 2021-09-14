//
//  PersistentContainer.swift
//  TweetNestKit
//
//  Created by Jaehong Kang on 2021/02/24.
//

import CloudKit
import CoreData
import OrderedCollections

public enum PersistentContainerError: Error {
    case persistentStoresLoadingFailure([NSPersistentStoreDescription: Error])
}

public class PersistentContainer: NSPersistentCloudKitContainer {
    public override class func defaultDirectoryURL() -> URL {
        Session.containerApplicationSupportURL
    }

    class var managedObjectModel: NSManagedObjectModel {
        let managedObjectModel = NSManagedObjectModel(contentsOf: Bundle.tweetNestKit.url(forResource: Bundle.tweetNestKit.name!, withExtension: "momd")!)!

        let accountEntity = managedObjectModel.entitiesByName["Account"]
        let usersFetchedPropertyDescription = accountEntity?.propertiesByName["users"] as? NSFetchedPropertyDescription
        usersFetchedPropertyDescription?.fetchRequest?.sortDescriptors = [
            NSSortDescriptor(keyPath: \User.creationDate, ascending: true),
            NSSortDescriptor(keyPath: \User.modificationDate, ascending: true),
        ]

        let userEntity = managedObjectModel.entitiesByName["User"]
        let accountsFetchedPropertyDescription = userEntity?.propertiesByName["accounts"] as? NSFetchedPropertyDescription
        accountsFetchedPropertyDescription?.fetchRequest?.sortDescriptors = [
            NSSortDescriptor(keyPath: \Account.creationDate, ascending: true),
        ]

        return managedObjectModel
    }

    class var defaultPersistentStoreURL: URL {
        Self.defaultDirectoryURL().appendingPathComponent("TweetNestKit.sqlite")
    }

    static let defaultPersistentStoreConfiguration = "TweetNestKit"

    class var accountsPersistentStoreURL: URL {
        Self.defaultDirectoryURL().appendingPathComponent("Accounts.sqlite")
    }

    static let accountsPersistentStoreConfiguration = "Accounts"

    public override var viewContext: NSManagedObjectContext {
        let viewContext = super.viewContext
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyStoreTrumpMergePolicyType)
        return viewContext
    }

    #if canImport(CoreSpotlight)
    var usersSpotlightDelegate: UsersSpotlightDelegate?
    #endif

    @Published
    public private(set) var cloudKitEvents: OrderedDictionary<UUID, PersistentContainer.CloudKitEvent> = [:]
    private nonisolated lazy var persistentContainerEventDidChanges = NotificationCenter.default
        .publisher(for: NSPersistentCloudKitContainer.eventChangedNotification, object: self)
        .compactMap { $0.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey] as? NSPersistentCloudKitContainer.Event }
        .sink { [weak self] event in
            self?.persistentStoreCoordinator.perform {  [weak self] in
                self?.cloudKitEvents[event.identifier] = PersistentContainer.CloudKitEvent(event)
            }
        }

    init(inMemory: Bool = false) {
        super.init(name: Bundle.tweetNestKit.name!, managedObjectModel: Self.managedObjectModel)

        _ = persistentContainerEventDidChanges

        let tweetNestKitPersistentStoreDescription = NSPersistentStoreDescription(url: Self.defaultPersistentStoreURL)
        tweetNestKitPersistentStoreDescription.configuration = Self.defaultPersistentStoreConfiguration
        tweetNestKitPersistentStoreDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: Session.cloudKitIdentifier)
        tweetNestKitPersistentStoreDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        tweetNestKitPersistentStoreDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        tweetNestKitPersistentStoreDescription.shouldAddStoreAsynchronously = true

        let accountsPersistentStoreDescription = NSPersistentStoreDescription(url: Self.accountsPersistentStoreURL)
        accountsPersistentStoreDescription.configuration = Self.accountsPersistentStoreConfiguration
        accountsPersistentStoreDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: Session.accountsCloudKitIdentifier)
        accountsPersistentStoreDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        accountsPersistentStoreDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        persistentStoreDescriptions = [
            accountsPersistentStoreDescription,
            tweetNestKitPersistentStoreDescription,
        ]

        self.persistentStoreDescriptions.forEach { description in
            if inMemory {
                description.url = URL(fileURLWithPath: "/dev/null")
            }
        }

        #if canImport(CoreSpotlight)
        self.usersSpotlightDelegate = inMemory == false ? UsersSpotlightDelegate(forStoreWith: tweetNestKitPersistentStoreDescription, coordinator: self.persistentStoreCoordinator) : nil
        #endif
    }

    @available(*, unavailable)
    public override func loadPersistentStores(completionHandler block: @escaping (NSPersistentStoreDescription, Error?) -> Void) {
        fatalError()
    }

    public func loadPersistentStores() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            persistentStoreCoordinator.perform {
                do {
                    try Self.migrationIfNeeded()

                    var loadedPersistentStores = [NSPersistentStoreDescription: Error?]()

                    super.loadPersistentStores { (storeDescription, error) in
                        loadedPersistentStores[storeDescription] = error

                        if loadedPersistentStores.count == self.persistentStoreDescriptions.count {
                            let errors = loadedPersistentStores.compactMapValues { $0 }

                            guard errors.isEmpty else {
                                continuation.resume(throwing: PersistentContainerError.persistentStoresLoadingFailure(errors))
                                return
                            }

                            #if canImport(CoreSpotlight)
                            if let usersSpotlightDelegate = self.usersSpotlightDelegate {
                                usersSpotlightDelegate.startSpotlightIndexing()
                            }
                            #endif

                            continuation.resume()
                        }
                    }
                } catch {
                    continuation.resume(throwing: error)
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
    private class func migrationIfNeeded() throws {
        guard FileManager.default.fileExists(atPath: defaultPersistentStoreURL.path) else {
            return
        }

        var isMigrated: Bool = false

        if FileManager.default.fileExists(atPath: accountsPersistentStoreURL.path) == false {
            // Step 1. Migrate default store with nil configuration

            let defaultModelMigrationPersistentContainer = NSPersistentContainer(name: "TweetNestKit", managedObjectModel: Self.managedObjectModel)
            defaultModelMigrationPersistentContainer.persistentStoreDescriptions[0].url = defaultPersistentStoreURL
            defaultModelMigrationPersistentContainer.persistentStoreDescriptions[0].setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)

            defaultModelMigrationPersistentContainer.loadPersistentStores { _, _ in }

            // Step 2. Migrate default store to account store

            let accountsStoreMigrationPersistentContainer = NSPersistentContainer(name: "Accounts", managedObjectModel: Self.managedObjectModel)
            accountsStoreMigrationPersistentContainer.persistentStoreDescriptions[0].configuration = Self.accountsPersistentStoreConfiguration
            accountsStoreMigrationPersistentContainer.persistentStoreDescriptions[0].url = defaultPersistentStoreURL
            accountsStoreMigrationPersistentContainer.persistentStoreDescriptions[0].setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            accountsStoreMigrationPersistentContainer.persistentStoreDescriptions[0].setOption(true as NSNumber, forKey: NSReadOnlyPersistentStoreOption)

            accountsStoreMigrationPersistentContainer.loadPersistentStores { _, _ in }

            if let store = accountsStoreMigrationPersistentContainer.persistentStoreCoordinator.persistentStores.first {
                _ = try accountsStoreMigrationPersistentContainer.persistentStoreCoordinator.migratePersistentStore(store, to: accountsPersistentStoreURL, options: nil, type: .sqlite)
            }

            isMigrated = true
        }

        if isMigrated { // Clean up default store
            // Step 1. Migrate default store to temp store, and migrate back to default store

            let defaultStoreMigrationPersistentContainer = NSPersistentContainer(name: "TweetNestKit", managedObjectModel: Self.managedObjectModel)
            defaultStoreMigrationPersistentContainer.persistentStoreDescriptions[0].configuration = Self.defaultPersistentStoreConfiguration
            defaultStoreMigrationPersistentContainer.persistentStoreDescriptions[0].url = defaultPersistentStoreURL
            defaultStoreMigrationPersistentContainer.persistentStoreDescriptions[0].setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            defaultStoreMigrationPersistentContainer.persistentStoreDescriptions[0].setOption(true as NSNumber, forKey: NSReadOnlyPersistentStoreOption)

            defaultStoreMigrationPersistentContainer.loadPersistentStores { _, _ in }

            if let store = defaultStoreMigrationPersistentContainer.persistentStoreCoordinator.persistentStores.first {
                let tempStore = try defaultStoreMigrationPersistentContainer.persistentStoreCoordinator.migratePersistentStore(store, to: defaultPersistentStoreURL.appendingPathExtension("temp"), options: nil, type: .sqlite)
                try defaultStoreMigrationPersistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: defaultPersistentStoreURL, type: .sqlite, options: nil)

                _ = try defaultStoreMigrationPersistentContainer.persistentStoreCoordinator.migratePersistentStore(tempStore, to: defaultPersistentStoreURL, options: nil, type: .sqlite)
                try defaultStoreMigrationPersistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: defaultPersistentStoreURL.appendingPathExtension("temp"), type: .sqlite, options: nil)
            }
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
