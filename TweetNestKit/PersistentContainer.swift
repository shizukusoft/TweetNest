//
//  PersistentContainer.swift
//  TweetNestKit
//
//  Created by Jaehong Kang on 2021/02/24.
//

import CloudKit
import CoreData

public class PersistentContainer: NSPersistentCloudKitContainer {
    public override class func defaultDirectoryURL() -> URL {
        return FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: Session.applicationGroupIdentifier)?
            .appendingPathComponent("Application Support/\(Bundle.module.name!)") ?? super.defaultDirectoryURL()
    }

    #if canImport(CoreSpotlight)
    var usersSpotlightDelegate: UsersSpotlightDelegate?
    #endif

    init(inMemory: Bool = false) {
        super.init(name: Bundle.module.name!, managedObjectModel: NSManagedObjectModel(contentsOf: Bundle.module.url(forResource: Bundle.module.name!, withExtension: "momd")!)!)

        persistentStoreDescriptions.forEach { description in
            if inMemory == false {
                description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: Session.cloudKitIdentifier)
                description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
                description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
            } else {
                description.url = URL(fileURLWithPath: "/dev/null")
            }
        }

        loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })

        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyStoreTrumpMergePolicyType)
        
        #if canImport(CoreSpotlight)
        if inMemory == false, let storeDescription = self.persistentStoreDescriptions.first(where: { $0.type == NSSQLiteStoreType }) {
            self.usersSpotlightDelegate = UsersSpotlightDelegate(forStoreWith: storeDescription, coordinator: self.persistentStoreCoordinator)
            self.usersSpotlightDelegate!.startSpotlightIndexing()
        }
        #endif
    }

    public override func newBackgroundContext() -> NSManagedObjectContext {
        let backgroundContext = super.newBackgroundContext()
        backgroundContext.automaticallyMergesChangesFromParent = true
        backgroundContext.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyStoreTrumpMergePolicyType)
        return backgroundContext
    }
}
