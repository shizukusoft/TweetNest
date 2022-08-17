//
//  ManagedUserDetail+CoreDataClass.swift
//  TweetNestKit
//
//  Created by 강재홍 on 2022/05/03.
//
//

import Foundation
import CoreData
import TwitterV1
import OrderedCollections

public class ManagedUserDetail: ManagedObject {

}

extension ManagedUserDetail {
    @discardableResult
    static func createOrUpdate(
        twitterUser: TwitterV1.User,
        followingUserIDs: [String]? = nil,
        followerUserIDs: [String]? = nil,
        blockingUserIDs: [String]? = nil,
        mutingUserIDs: [String]? = nil,
        creationDate: Date = Date(),
        previousUserDetail: ManagedUserDetail? = nil,
        context: NSManagedObjectContext
    ) throws -> ManagedUserDetail {
        let newUserDetail = ManagedUserDetail(context: context)
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

extension ManagedUserDetail {
    public var displayUsername: String? {
        username.flatMap {
            "@\($0)"
        }
    }
}

extension ManagedUserDetail {
    static func ~= (lhs: ManagedUserDetail, rhs: ManagedUserDetail) -> Bool {
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

extension Optional where Wrapped == ManagedUserDetail {
    static func ~= (lhs: ManagedUserDetail?, rhs: ManagedUserDetail?) -> Bool {
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

extension ManagedUserDetail {
    func isProfileEqual(to userDetail: ManagedUserDetail) -> Bool {
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

extension ManagedUserDetail {
    struct UserIDsChange {
        let addedUserIDs: OrderedSet<String>
        let removedUserIDs: OrderedSet<String>
    }

    func userIDsChange(from oldUserDetail: ManagedUserDetail?, for keyPath: KeyPath<ManagedUserDetail, [String]?>) -> UserIDsChange? {
        let previousUserIDs = oldUserDetail == nil ? [] : oldUserDetail?[keyPath: keyPath].flatMap { OrderedSet($0) }
        let latestUserIDs = self[keyPath: keyPath].flatMap { OrderedSet($0) }

        guard let previousUserIDs = previousUserIDs, let latestUserIDs = latestUserIDs else {
            return nil
        }

        return UserIDsChange(
            addedUserIDs: latestUserIDs.subtracting(previousUserIDs),
            removedUserIDs: previousUserIDs.subtracting(latestUserIDs)
        )
    }
}
