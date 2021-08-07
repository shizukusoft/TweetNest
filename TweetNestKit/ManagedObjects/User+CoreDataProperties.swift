//
//  User+CoreDataProperties.swift
//  User
//
//  Created by Jaehong Kang on 2021/07/31.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var creationDate: Date?
    @NSManaged public var id: String
    @NSManaged public var lastUpdateStartDate: Date?
    @NSManaged public var lastUpdateEndDate: Date?
    @NSManaged public var modificationDate: Date?
    @NSManaged public var account: Account?
    @NSManaged public var userDatas: NSSet?

}

// MARK: Generated accessors for userDatas
extension User {

    @objc(addUserDatasObject:)
    @NSManaged public func addToUserDatas(_ value: UserData)

    @objc(removeUserDatasObject:)
    @NSManaged public func removeFromUserDatas(_ value: UserData)

    @objc(addUserDatas:)
    @NSManaged public func addToUserDatas(_ values: NSSet)

    @objc(removeUserDatas:)
    @NSManaged public func removeFromUserDatas(_ values: NSSet)

}
