//
//  User+CoreDataProperties.swift
//  TweetNestKit
//
//  Created by Jaehong Kang on 2021/03/22.
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
    @NSManaged public var account: Account?
    @NSManaged public var followingUsers: NSOrderedSet?
    @NSManaged public var followerUsers: NSOrderedSet?

}

// MARK: Generated accessors for followingUsers
extension User {

    @objc(insertObject:inFollowingUsersAtIndex:)
    @NSManaged public func insertIntoFollowingUsers(_ value: User, at idx: Int)

    @objc(removeObjectFromFollowingUsersAtIndex:)
    @NSManaged public func removeFromFollowingUsers(at idx: Int)

    @objc(insertFollowingUsers:atIndexes:)
    @NSManaged public func insertIntoFollowingUsers(_ values: [User], at indexes: NSIndexSet)

    @objc(removeFollowingUsersAtIndexes:)
    @NSManaged public func removeFromFollowingUsers(at indexes: NSIndexSet)

    @objc(replaceObjectInFollowingUsersAtIndex:withObject:)
    @NSManaged public func replaceFollowingUsers(at idx: Int, with value: User)

    @objc(replaceFollowingUsersAtIndexes:withFollowingUsers:)
    @NSManaged public func replaceFollowingUsers(at indexes: NSIndexSet, with values: [User])

    @objc(addFollowingUsersObject:)
    @NSManaged public func addToFollowingUsers(_ value: User)

    @objc(removeFollowingUsersObject:)
    @NSManaged public func removeFromFollowingUsers(_ value: User)

    @objc(addFollowingUsers:)
    @NSManaged public func addToFollowingUsers(_ values: NSOrderedSet)

    @objc(removeFollowingUsers:)
    @NSManaged public func removeFromFollowingUsers(_ values: NSOrderedSet)

}

// MARK: Generated accessors for followerUsers
extension User {

    @objc(insertObject:inFollowerUsersAtIndex:)
    @NSManaged public func insertIntoFollowerUsers(_ value: User, at idx: Int)

    @objc(removeObjectFromFollowerUsersAtIndex:)
    @NSManaged public func removeFromFollowerUsers(at idx: Int)

    @objc(insertFollowerUsers:atIndexes:)
    @NSManaged public func insertIntoFollowerUsers(_ values: [User], at indexes: NSIndexSet)

    @objc(removeFollowerUsersAtIndexes:)
    @NSManaged public func removeFromFollowerUsers(at indexes: NSIndexSet)

    @objc(replaceObjectInFollowerUsersAtIndex:withObject:)
    @NSManaged public func replaceFollowerUsers(at idx: Int, with value: User)

    @objc(replaceFollowerUsersAtIndexes:withFollowerUsers:)
    @NSManaged public func replaceFollowerUsers(at indexes: NSIndexSet, with values: [User])

    @objc(addFollowerUsersObject:)
    @NSManaged public func addToFollowerUsers(_ value: User)

    @objc(removeFollowerUsersObject:)
    @NSManaged public func removeFromFollowerUsers(_ value: User)

    @objc(addFollowerUsers:)
    @NSManaged public func addToFollowerUsers(_ values: NSOrderedSet)

    @objc(removeFollowerUsers:)
    @NSManaged public func removeFromFollowerUsers(_ values: NSOrderedSet)

}

extension User : Identifiable {

}
