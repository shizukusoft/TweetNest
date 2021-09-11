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

    init(inMemory: Bool = false) throws {
        super.init(name: Bundle.tweetNestKit.name!, managedObjectModel: NSManagedObjectModel(contentsOf: Bundle.tweetNestKit.url(forResource: Bundle.tweetNestKit.name!, withExtension: "momd")!)!)

        _ = persistentContainerEventDidChanges

        let persistentStoreGroup = DispatchGroup()
        persistentStoreDescriptions.forEach { description in
            persistentStoreGroup.enter()

            if inMemory == false {
                description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: Session.cloudKitIdentifier)
                description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
                description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
            } else {
                description.url = URL(fileURLWithPath: "/dev/null")
            }
        }

        var loadPersistentStoreErrors = [NSPersistentStoreDescription: Error]()
        loadPersistentStores { (storeDescription, error) in
            loadPersistentStoreErrors[storeDescription] = error
            persistentStoreGroup.leave()
        }

        persistentStoreGroup.wait()

        guard loadPersistentStoreErrors.isEmpty else {
            throw PersistentContainerError.persistentStoresLoadingFailure(loadPersistentStoreErrors)
        }

        #if canImport(CoreSpotlight)
        if inMemory == false, let storeDescription = self.persistentStoreDescriptions.first(where: { $0.type == NSSQLiteStoreType }) {
            self.usersSpotlightDelegate = UsersSpotlightDelegate(forStoreWith: storeDescription, coordinator: self.persistentStoreCoordinator)
            self.usersSpotlightDelegate!.startSpotlightIndexing()
        }
        #endif

        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyStoreTrumpMergePolicyType)
    }

    public override func newBackgroundContext() -> NSManagedObjectContext {
        let backgroundContext = super.newBackgroundContext()
        backgroundContext.automaticallyMergesChangesFromParent = true
        backgroundContext.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyStoreTrumpMergePolicyType)
        return backgroundContext
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
