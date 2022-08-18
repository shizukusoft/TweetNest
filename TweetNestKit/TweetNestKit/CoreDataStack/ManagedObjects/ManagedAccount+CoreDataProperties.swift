//
//  ManagedAccount+CoreDataProperties.swift
//  TweetNestKit
//
//  Created by Jaehong Kang on 2022/05/03.
//
//

import Foundation
import CoreData

extension ManagedAccount {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedAccount> {
        return NSFetchRequest<ManagedAccount>(entityName: "Account")
    }

    @NSManaged public var creationDate: Date?
    @NSManaged public var preferringSortOrder: Int64
    @NSManaged public var token: String?
    @NSManaged public var tokenSecret: String?
    @NSManaged public var userID: String?

}

extension ManagedAccount: Identifiable {

}
