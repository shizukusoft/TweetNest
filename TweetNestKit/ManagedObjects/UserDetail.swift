//
//  UserDetail.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/02/26.
//
//

import Foundation
import CoreData
import TwitterV1

public class UserDetail: NSManagedObject {

}

extension UserDetail {
    @discardableResult
    static func createOrUpdate(
        twitterUser: TwitterV1.User,
        followingUserIDs: [String]? = nil,
        followerUserIDs: [String]? = nil,
        blockingUserIDs: [String]? = nil,
        mutingUserIDs: [String]? = nil,
        creationDate: Date = Date(),
        user: User,
        previousUserDetail: UserDetail? = nil,
        context: NSManagedObjectContext
    ) throws -> UserDetail {
        let previousUserDetail = previousUserDetail ?? user.sortedUserDetails?.last

        let newUserDetail = UserDetail(context: context)
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
            newUserDetail.user = user
            newUserDetail.user!.modificationDate = creationDate

            return newUserDetail
        }
    }
}

extension UserDetail {
    public var displayUsername: String? {
        username.flatMap {
            "@\($0)"
        }
    }
}

extension UserDetail {
    static func ~= (lhs: UserDetail, rhs: UserDetail) -> Bool {
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

extension Optional where Wrapped == UserDetail {
    static func ~= (lhs: UserDetail?, rhs: UserDetail?) -> Bool {
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

extension UserDetail {
    func isProfileEqual(to userDetail: UserDetail) -> Bool {
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

extension UserDetail {
    func userIDsChanges(from oldUserDetail: UserDetail?, for keyPath: KeyPath<UserDetail, [String]?>) -> (addedUserIDsCount: Int, removedUserIDsCount: Int)? {
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
