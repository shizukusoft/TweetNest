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
        guard let userDetails = userDetails as? Set<UserDetail> else {
            return nil
        }

        let sortedUserDetailObjectIDs: OrderedSet<NSManagedObjectID>? = try? managedObjectContext.flatMap { managedObjectContext in
            let fetchRequest = NSFetchRequest<NSManagedObjectID>()
            fetchRequest.entity = UserDetail.entity()
            fetchRequest.resultType = .managedObjectIDResultType
            fetchRequest.predicate = NSPredicate(format: "user == %@", self)
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(keyPath: \UserDetail.creationDate, ascending: true)
            ]
            fetchRequest.includesPropertyValues = true

            let results = try managedObjectContext.fetch(fetchRequest)

            return OrderedSet(results)
        }

        var sortedUserDetails = OrderedSet(userDetails)

        sortedUserDetails.sort { lhs, rhs in
            if
                let lhsIndex = sortedUserDetailObjectIDs?.firstIndex(of: lhs.objectID),
                let rhsIndex = sortedUserDetailObjectIDs?.firstIndex(of: rhs.objectID)
            {
                return lhsIndex < rhsIndex
            } else {
                return lhs.creationDate ?? .distantPast < rhs.creationDate ?? .distantPast
            }
        }

        return sortedUserDetails
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
