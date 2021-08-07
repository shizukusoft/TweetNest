//
//  UserData+CoreDataProperties.swift
//  UserData
//
//  Created by Jaehong Kang on 2021/08/01.
//
//

import Foundation
import CoreData


extension UserData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserData> {
        return NSFetchRequest<UserData>(entityName: "UserData")
    }

    @NSManaged public var creationDate: Date?

    @NSManaged public var blockingUserIDs: [String]?
    @NSManaged public var followerUserIDs: [String]?
    @NSManaged public var followingUserIDs: [String]?

    @NSManaged public var followersCount: Int32
    @NSManaged public var followingUsersCount: Int32
    @NSManaged public var isProtected: Bool
    @NSManaged public var isVerified: Bool
    @NSManaged public var listedCount: Int32
    @NSManaged public var location: String?
    @NSManaged public var name: String?
    @NSManaged public var profileImageURL: URL?
    @NSManaged public var tweetsCount: Int32
    @NSManaged public var url: URL?
    @NSManaged public var userCreationDate: Date?
    @NSManaged public var userAttributedDescription: NSAttributedString?
    @NSManaged public var username: String?
    @NSManaged public var user: User?
}
