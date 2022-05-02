//
//  ManagedUserDetailV2+CoreDataClass.swift
//  TweetNestKit
//
//  Created by 강재홍 on 2022/05/02.
//
//

import Foundation
import CoreData
import TwitterV1

public class ManagedUserDetailV2: NSManagedObject { }

extension ManagedUserDetailV2 {
    @NSManaged public private(set) var users: [User]? // The accessor of the users property.
}

extension ManagedUserDetailV2 {
    @discardableResult
    static func createOrUpdate(
        twitterUser: TwitterV1.User,
        followingUserIDs: [String]? = nil,
        followerUserIDs: [String]? = nil,
        blockingUserIDs: [String]? = nil,
        mutingUserIDs: [String]? = nil,
        creationDate: Date = Date(),
        previousUserDetail: ManagedUserDetailV2? = nil,
        context: NSManagedObjectContext
    ) throws -> ManagedUserDetailV2 {
        let previousUserDetail = previousUserDetail

        let newUserDetail = ManagedUserDetailV2(context: context)
        newUserDetail.userID = String(twitterUser.id)

        newUserDetail.blockingUserIDs = blockingUserIDs
        newUserDetail.followingUserIDs = followingUserIDs
        newUserDetail.followerUserIDs = followerUserIDs
        newUserDetail.mutingUserIDs = mutingUserIDs

        newUserDetail.followerUsersCount = Int32(twitterUser.followersCount)
        newUserDetail.followingUsersCount = Int32(twitterUser.friendsCount)
        newUserDetail.isProtected = twitterUser.isProtected
        newUserDetail.isVerified = twitterUser.isVerified
        newUserDetail.listedCount = Int32(twitterUser.listedCount)
        newUserDetail.location = twitterUser.location
        newUserDetail.name = twitterUser.name
        newUserDetail.profileHeaderImageURL = twitterUser.profileBannerOriginalURL
        newUserDetail.profileImageURL = twitterUser.profileImageOriginalURL
        newUserDetail.tweetsCount = Int32(twitterUser.statusesCount)
        newUserDetail.url = twitterUser.expandedURL
        newUserDetail.userCreationDate = twitterUser.createdAt
        newUserDetail.userAttributedDescription = twitterUser.attributedDescription.flatMap({ NSAttributedString($0) })
        newUserDetail.username = twitterUser.screenName

        if let previousUserDetail = previousUserDetail, previousUserDetail ~= newUserDetail {
            context.delete(newUserDetail)

            return previousUserDetail
        } else {
            newUserDetail.creationDate = creationDate

            return newUserDetail
        }
    }
}

extension ManagedUserDetailV2 {
    public var displayUsername: String? {
        username.flatMap {
            "@\($0)"
        }
    }
}

extension ManagedUserDetailV2 {
    static func ~= (lhs: ManagedUserDetailV2, rhs: ManagedUserDetailV2) -> Bool {
        lhs.isProfileEqual(to: rhs) &&
        lhs.followerUsersCount == rhs.followerUsersCount &&
        lhs.followingUsersCount == rhs.followingUsersCount &&
        lhs.listedCount == rhs.listedCount &&
        lhs.tweetsCount == rhs.tweetsCount &&
        lhs.blockingUserIDs == rhs.blockingUserIDs &&
        lhs.followingUserIDs == rhs.followingUserIDs &&
        lhs.followerUserIDs == rhs.followerUserIDs &&
        lhs.mutingUserIDs == rhs.mutingUserIDs
    }
}

extension Optional where Wrapped == ManagedUserDetailV2 {
    static func ~= (lhs: Self?, rhs: Self?) -> Bool {
        switch (lhs, rhs) {
        case (.some, .none), (.none, .some):
            return false
        case (.none, .none):
            return true
        case (.some(let lhs), .some(let rhs)):
            return lhs ~= rhs
        }
    }
}

extension ManagedUserDetailV2 {
    func isProfileEqual(to userDetail: ManagedUserDetailV2) -> Bool {
        isProtected == userDetail.isProtected &&
        isVerified == userDetail.isVerified &&
        location == userDetail.location &&
        name == userDetail.name &&
        profileHeaderImageURL == userDetail.profileHeaderImageURL &&
        profileImageURL == userDetail.profileImageURL &&
        url == userDetail.url &&
        userCreationDate == userDetail.userCreationDate &&
        userAttributedDescription == userDetail.userAttributedDescription &&
        username == userDetail.username
    }
}

extension ManagedUserDetailV2 {
    func userIDsChanges(from oldUserDetail: ManagedUserDetailV2?, for keyPath: KeyPath<ManagedUserDetailV2, [String]?>) -> (addedUserIDsCount: Int, removedUserIDsCount: Int)? {
        let previousUserIDs = oldUserDetail == nil ? [] : oldUserDetail?[keyPath: keyPath].flatMap { Set($0) }
        let latestUserIDs = self[keyPath: keyPath].flatMap { Set($0) }

        guard let previousUserIDs = previousUserIDs, let latestUserIDs = latestUserIDs else {
            return nil
        }

        let addedUserIDsCount = latestUserIDs.subtracting(previousUserIDs).count
        let removedUserIDsCount = previousUserIDs.subtracting(latestUserIDs).count

        return (addedUserIDsCount, removedUserIDsCount)
    }
}
