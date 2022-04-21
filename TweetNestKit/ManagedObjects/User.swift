//
//  User.swift
//  TweetNestKit
//
//  Created by Jaehong Kang on 2021/02/25.
//

import Foundation
import OrderedCollections
import CoreData
import Twitter

public class User: NSManagedObject {
    public dynamic var sortedUserDetails: OrderedSet<UserDetail>? {
        (userDetails as? Set<UserDetail>).flatMap {
            var sortedUserDetails = OrderedSet($0)

            let sortedManagedObjectID: OrderedSet<NSManagedObjectID>? = managedObjectContext
                .flatMap { context in
                    let userDetailsObjectIDs = Set(sortedUserDetails.map(\.objectID))

                    let fetchRequest = NSFetchRequest<NSManagedObjectID>()
                    fetchRequest.entity = UserDetail.entity()
                    fetchRequest.predicate = NSPredicate(format: "user == %@", objectID)
                    fetchRequest.sortDescriptors = [
                        NSSortDescriptor(keyPath: \UserDetail.creationDate, ascending: true)
                    ]
                    fetchRequest.resultType = .managedObjectIDResultType

                    guard let sortedManagedObjectID = (try? context.fetch(fetchRequest)).flatMap({ OrderedSet($0) }) else {
                        return nil
                    }

                    guard sortedManagedObjectID.isSuperset(of: userDetailsObjectIDs) else {
                        return nil
                    }

                    return sortedManagedObjectID
                }

            if let sortedManagedObjectID = sortedManagedObjectID {
                sortedUserDetails.sort { (sortedManagedObjectID.firstIndex(of: $0.objectID) ?? .min) < (sortedManagedObjectID.firstIndex(of: $1.objectID) ?? .min) }
            } else {
                sortedUserDetails.sort { $0.creationDate ?? .distantPast < $1.creationDate ?? .distantPast }
            }

            return sortedUserDetails
        }
    }

    public override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        let keyPaths = super.keyPathsForValuesAffectingValue(forKey: key)
        switch key {
        case "sortedUserDetails":
            return keyPaths.union(Set(["userDetails"]))
        default:
            return keyPaths
        }
    }
}

extension User {
    @NSManaged public private(set) var accounts: [Account]? // The accessor of the accounts property.
}
