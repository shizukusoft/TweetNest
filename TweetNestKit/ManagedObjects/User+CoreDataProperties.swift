//
//  User+CoreDataProperties.swift
//  User
//
//  Created by Jaehong Kang on 2021/09/14.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var creationDate: Date?
    @NSManaged public var id: String?
    @NSManaged public var lastUpdateEndDate: Date?
    @NSManaged public var lastUpdateStartDate: Date?
    @NSManaged public var modificationDate: Date?
    @NSManaged public var userDetails: NSSet?

}

// MARK: Generated accessors for userDetails
extension User {

    @objc(addUserDetailsObject:)
    @NSManaged public func addToUserDetails(_ value: UserDetail)

    @objc(removeUserDetailsObject:)
    @NSManaged public func removeFromUserDetails(_ value: UserDetail)

    @objc(addUserDetails:)
    @NSManaged public func addToUserDetails(_ values: NSSet)

    @objc(removeUserDetails:)
    @NSManaged public func removeFromUserDetails(_ values: NSSet)

}

extension User : Identifiable {

}
