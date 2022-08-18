//
//  ManagedObject+CoreDataClass.swift
//  TweetNestKit
//
//  Created by Jaehong Kang on 2022/08/13.
//
//

import Foundation
import CoreData
import BackgroundTask
import UnifiedLogging

public class ManagedObject: NSManagedObject {
    @objc
    public dynamic var persistentID: UUID? {
        get {
            willAccessValue(forKey: (\ManagedObject.persistentID)._kvcKeyPathString!)
            let persistentID = primitiveValue(forKey: (\ManagedObject.persistentID)._kvcKeyPathString!)
            didAccessValue(forKey: (\ManagedObject.persistentID)._kvcKeyPathString!)

            guard let persistentID = persistentID as? UUID else {
                do {
                    try updatePersistentID()
                } catch {
                    Logger(subsystem: Bundle.tweetNestKit.bundleIdentifier!, category: String(reflecting: ManagedObject.self))
                        .error("Error occurred while update persistentID for \(self.objectID, privacy: .public): \(error as NSError, privacy: .public)")
                }

                willAccessValue(forKey: (\ManagedObject.persistentID)._kvcKeyPathString!)
                defer {
                    didAccessValue(forKey: (\ManagedObject.persistentID)._kvcKeyPathString!)
                }
                return primitiveValue(forKey: (\ManagedObject.persistentID)._kvcKeyPathString!) as? UUID
            }

            return persistentID
        }
        set {
            willChangeValue(forKey: (\ManagedObject.persistentID)._kvcKeyPathString!)
            setPrimitiveValue(newValue, forKey: (\ManagedObject.persistentID)._kvcKeyPathString!)
            didChangeValue(forKey: (\ManagedObject.persistentID)._kvcKeyPathString!)
        }
    }

    public override func awakeFromInsert() {
        super.awakeFromInsert()

        setPrimitiveValue(UUID(), forKey: (\ManagedObject.persistentID)._kvcKeyPathString!)
    }

    private func updatePersistentID() throws {
        guard
            let managedObjectContext = managedObjectContext
        else {
            return
        }

        let batchUpdateRequest = NSBatchUpdateRequest(entity: entity)
        batchUpdateRequest.resultType = .updatedObjectIDsResultType
        batchUpdateRequest.predicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: [
                NSPredicate(format: "SELF == %@", objectID),
                NSPredicate(format: "persistentID == NULL")
            ]
        )

        let propertiesToUpdate = [(\ManagedObject.persistentID)._kvcKeyPathString: UUID()]
        batchUpdateRequest.propertiesToUpdate = propertiesToUpdate

        let persistentStoreResult = try managedObjectContext.execute(batchUpdateRequest)

        guard
            let batchUpdateResult = persistentStoreResult as? NSBatchUpdateResult,
            let updatedObjectIDs = batchUpdateResult.result as? [NSManagedObjectID]
        else {
            return
        }

        guard !updatedObjectIDs.isEmpty else {
            return
        }

        let changes = [NSUpdatedObjectsKey: updatedObjectIDs]
        NSManagedObjectContext.mergeChanges(
            fromRemoteContextSave: changes,
            into: [managedObjectContext]
        )
    }
}
