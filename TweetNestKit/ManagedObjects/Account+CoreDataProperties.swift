//
//  Account+CoreDataProperties.swift
//  Account
//
//  Created by Jaehong Kang on 2021/08/16.
//
//

import Foundation
import CoreData


extension Account {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Account> {
        return NSFetchRequest<Account>(entityName: "Account")
    }

    @NSManaged public var creationDate: Date?
    @NSManaged public var id: Int64
    @NSManaged public var token: String?
    @NSManaged public var tokenSecret: String?
    @NSManaged public var preferringSortOrder: Int64
    @NSManaged public var user: User?

}

extension Account : Identifiable {

}
