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
            var userDetails = OrderedSet($0)

            let fetchRequest = NSFetchRequest<NSManagedObjectID>()
            fetchRequest.entity = UserDetail.entity()
            fetchRequest.predicate = NSPredicate(format: "user == %@", self)
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(keyPath: \UserDetail.creationDate, ascending: true)
            ]
            fetchRequest.resultType = .managedObjectIDResultType

            let sortedManagedObjectID = try? managedObjectContext?.fetch(fetchRequest)

            if let sortedManagedObjectID = sortedManagedObjectID.flatMap({ OrderedSet($0) }) {
                userDetails.sort { (sortedManagedObjectID.firstIndex(of: $0.objectID) ?? -1) < (sortedManagedObjectID.firstIndex(of: $1.objectID) ?? -1) }
            } else {
                userDetails.sort { $0.creationDate ?? .distantPast < $1.creationDate ?? .distantPast }
            }

            return userDetails
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
