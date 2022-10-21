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

public final class PersistentContainer: NSPersistentCloudKitContainer {
    public override class func defaultDirectoryURL() -> URL {
        Session.containerApplicationSupportURL
    }

    public override var viewContext: NSManagedObjectContext {
        let viewContext = super.viewContext
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return viewContext
    }

    #if canImport(CoreSpotlight)
    public private(set) var usersSpotlightDelegate: UsersSpotlightDelegate?

    private var usersSpotlightPersistentStoreDescription: NSPersistentStoreDescription {
        persistentStoreDescriptions[0]
    }
    #endif

    @MainActor @Published
    public private(set) var cloudKitEvents: OrderedDictionary<UUID, NSPersistentCloudKitContainer.Event> = [:]

    init(inMemory: Bool = false, persistentStoreOptions: [String: Any?]? = nil) {
        super.init(name: "\(Bundle.tweetNestKit.name!).V3", managedObjectModel: Self.V3.managedObjectModel)

        if !inMemory {
            persistentStoreDescriptions = [
                Self.V3.userDataPersistentStoreDescription,
                Self.V3.defaultPersistentStoreDescription,
            ].lazy.map { persistentStoreDescription in
                persistentStoreDescription.type = NSSQLiteStoreType
                persistentStoreDescription.shouldAddStoreAsynchronously = true
                persistentStoreDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
                persistentStoreDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

                if let persistentStoreOptions = persistentStoreOptions {
                    for (key, option) in persistentStoreOptions {
                        persistentStoreDescription.setOption(option == nil ? nil : option as? NSObject, forKey: key)
                    }
                }

                return persistentStoreDescription
            }
        } else {
            persistentStoreDescriptions.forEach {
                $0.url = nil
                $0.type = NSInMemoryStoreType
                $0.shouldAddStoreAsynchronously = true
                $0.cloudKitContainerOptions = nil
                if let persistentStoreOptions = persistentStoreOptions {
                    for (key, option) in persistentStoreOptions {
                        $0.setOption(option == nil ? nil : option as? NSObject, forKey: key)
                    }
                }
            }
        }

        NotificationCenter.default
            .publisher(for: NSPersistentCloudKitContainer.eventChangedNotification, object: self)
            .compactMap { $0.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey] as? NSPersistentCloudKitContainer.Event }
            .scan(OrderedDictionary<UUID, NSPersistentCloudKitContainer.Event>()) {
                var cloudKitEvents = $0

                cloudKitEvents[$1.identifier] = $1

                return cloudKitEvents
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$cloudKitEvents)
    }

    public override func loadPersistentStores(completionHandler block: @escaping (NSPersistentStoreDescription, Error?) -> Void) {
        persistentStoreCoordinator.performAndWait {
            do {
                try self.migrateIfNeeded()

                super.loadPersistentStores(completionHandler: block)

                #if canImport(CoreSpotlight)
                if
                    usersSpotlightPersistentStoreDescription.type == NSSQLiteStoreType,
                    usersSpotlightPersistentStoreDescription.options[NSPersistentHistoryTrackingKey] == true as NSNumber
                {
                    self.usersSpotlightDelegate = UsersSpotlightDelegate(
                        forStoreWith: self.usersSpotlightPersistentStoreDescription,
                        coordinator: self.persistentStoreCoordinator
                    )
                }
                #endif
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
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return backgroundContext
    }
}
