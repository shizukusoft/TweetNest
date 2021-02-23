//
//  Account+CoreDataProperties.swift
//  TweetNestKit
//
//  Created by Jaehong Kang on 2021/02/23.
//
//

import Foundation
import CoreData


extension Account {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Account> {
        return NSFetchRequest<Account>(entityName: "Account")
    }

    @NSManaged public var id: Int64
    @NSManaged public var addedAt: Date?

}

extension Account : Identifiable {

}
