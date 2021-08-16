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

public class User: NSManagedObject, Identifiable {
    public dynamic var sortedUserDatas: OrderedSet<UserData>? {
        userDatas.flatMap {
            OrderedSet(
                $0.lazy
                    .compactMap { $0 as? UserData }
                    .sorted { $0.creationDate ?? .distantPast < $1.creationDate ?? .distantPast }
            )
        }
    }

    public override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        let keyPaths = super.keyPathsForValuesAffectingValue(forKey: key)
        switch key {
        case "sortedUserDatas":
            return keyPaths.union(Set(["userDatas"]))
        default:
            return keyPaths
        }
    }
}
