//
//  ManagedUserDetail+CoreDataProperties.swift
//  TweetNestKit
//
//  Created by 강재홍 on 2022/05/03.
//
//

import Foundation
import CoreData

extension ManagedUserDetail {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedUserDetail> {
        return NSFetchRequest<ManagedUserDetail>(entityName: "UserDetail")
    }

    @NSManaged public var blockingUserIDs: [String]?
    @NSManaged public var creationDate: Date?
    @NSManaged public var followerUserIDs: [String]?
    @NSManaged public var followerUsersCount: Int32
    @NSManaged public var followingUserIDs: [String]?
    @NSManaged public var followingUsersCount: Int32
    @NSManaged public var isProtected: Bool
    @NSManaged public var isVerified: Bool
    @NSManaged public var listedCount: Int32
    @NSManaged public var location: String?
    @NSManaged public var mutingUserIDs: [String]?
    @NSManaged public var name: String?
    @NSManaged public var profileHeaderImageURL: URL?
    @NSManaged public var profileImageURL: URL?
    @NSManaged public var tweetsCount: Int32
    @NSManaged public var url: URL?
    @NSManaged public var userAttributedDescription: NSAttributedString?
    @NSManaged public var userCreationDate: Date?
    @NSManaged public var userID: String?
    @NSManaged public var username: String?

}

extension ManagedUserDetail: Identifiable {

}
