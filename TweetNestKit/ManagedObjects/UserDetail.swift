//
//  UserDetail.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/02/26.
//
//

import Foundation
import CoreData
import Twitter

public class UserDetail: NSManagedObject {

}

extension UserDetail {
    @discardableResult
    static func createOrUpdate(
        twitterUser: Twitter.User,
        profileHeaderImageURL: URL?,
        followingUserIDs: [String]? = nil,
        followerUserIDs: [String]? = nil,
        blockingUserIDs: [String]? = nil,
        mutingUserIDs: [String]? = nil,
        userUpdateStartDate: Date = Date(),
        userUpdateEndDate: Date = Date(),
        userDetailCreationDate: Date = Date(),
        context: NSManagedObjectContext
    ) throws -> UserDetail {
        let userFetchRequest: NSFetchRequest<User> = User.fetchRequest()
        userFetchRequest.predicate = NSPredicate(format: "id == %@", twitterUser.id)
        userFetchRequest.sortDescriptors = [NSSortDescriptor(key: "modificationDate", ascending: false)]
        userFetchRequest.fetchLimit = 1
        userFetchRequest.relationshipKeyPathsForPrefetching = ["userDetails"]
        userFetchRequest.returnsObjectsAsFaults = false

        let user = try context.fetch(userFetchRequest).first ?? {
            let user = User(context: context)
            user.id = twitterUser.id
            user.creationDate = userDetailCreationDate

            return user
        }()

        user.lastUpdateStartDate = userUpdateStartDate
        user.lastUpdateEndDate = userUpdateEndDate

        let newUserDetail = UserDetail(context: context)
        newUserDetail.blockingUserIDs = blockingUserIDs
        newUserDetail.followingUserIDs = followingUserIDs
        newUserDetail.followerUserIDs = followerUserIDs
        newUserDetail.mutingUserIDs = mutingUserIDs

        newUserDetail.followerUsersCount = Int32(twitterUser.publicMetrics.followersCount)
        newUserDetail.followingUsersCount = Int32(twitterUser.publicMetrics.followingUsersCount)
        newUserDetail.isProtected = twitterUser.protected
        newUserDetail.isVerified = twitterUser.verified
        newUserDetail.listedCount = Int32(twitterUser.publicMetrics.listedCount)
        newUserDetail.location = twitterUser.location
        newUserDetail.name = twitterUser.name
        newUserDetail.profileHeaderImageURL = profileHeaderImageURL
        newUserDetail.profileImageURL = twitterUser.profileImageOriginalURL
        newUserDetail.tweetsCount = Int32(twitterUser.publicMetrics.tweetsCount)
        newUserDetail.url = twitterUser.expandedURL
        newUserDetail.userCreationDate = twitterUser.createdAt
        newUserDetail.userAttributedDescription = twitterUser.attributedDescription.flatMap({ NSAttributedString($0) })
        newUserDetail.username = twitterUser.username

        if let lastUserDetail = user.sortedUserDetails?.last, lastUserDetail ~= newUserDetail {
            context.delete(newUserDetail)

            return lastUserDetail
        } else {
            newUserDetail.creationDate = userDetailCreationDate
            newUserDetail.user = user
            newUserDetail.user!.modificationDate = userDetailCreationDate

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
        lhs.blockingUserIDs == rhs.blockingUserIDs &&
        lhs.followingUserIDs == rhs.followingUserIDs &&
        lhs.followerUserIDs == rhs.followerUserIDs &&
        lhs.followerUsersCount == rhs.followerUsersCount &&
        lhs.followingUsersCount == rhs.followingUsersCount &&
        lhs.listedCount == rhs.listedCount &&
        lhs.mutingUserIDs == rhs.mutingUserIDs &&
        lhs.tweetsCount == rhs.tweetsCount
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

    func followingUserChanges(from oldUserDetail: UserDetail?) -> (followingUsersCount: Int, unfollowingUsersCount: Int) {
        let previousFollowingUserIDs = oldUserDetail == nil ? [] : oldUserDetail?.followingUserIDs.flatMap { Set($0) }
        let latestFollowingUserIDs = followingUserIDs.flatMap { Set($0) }

        let newFollowingUsersCount: Int
        let newUnfollowingUsersCount: Int

        if let latestFollowingUserIDs = latestFollowingUserIDs, let previousFollowingUserIDs = previousFollowingUserIDs {
            newFollowingUsersCount = latestFollowingUserIDs.subtracting(previousFollowingUserIDs).count
            newUnfollowingUsersCount = previousFollowingUserIDs.subtracting(latestFollowingUserIDs).count
        } else {
            newFollowingUsersCount = max(Int(followingUsersCount) - Int(oldUserDetail?.followingUsersCount ?? 0), 0)
            newUnfollowingUsersCount = max(Int(oldUserDetail?.followingUsersCount ?? 0) - Int(followingUsersCount), 0)
        }

        return (newFollowingUsersCount, newUnfollowingUsersCount)
    }

    func followerUserChanges(from oldUserDetail: UserDetail?) -> (followerUsersCount: Int, unfollowerUsersCount: Int) {
        let previousFollowerUserIDs = oldUserDetail == nil ? [] : oldUserDetail?.followerUserIDs.flatMap { Set($0) }
        let latestFollowerUserIDs = followerUserIDs.flatMap { Set($0) }

        let newFollowerUsersCount: Int
        let newUnfollowerUsersCount: Int

        if let latestFollowerUserIDs = latestFollowerUserIDs, let previousFollowerUserIDs = previousFollowerUserIDs {
            newFollowerUsersCount = latestFollowerUserIDs.subtracting(previousFollowerUserIDs).count
            newUnfollowerUsersCount = previousFollowerUserIDs.subtracting(latestFollowerUserIDs).count
        } else {
            newFollowerUsersCount = max(Int(followerUsersCount) - Int(oldUserDetail?.followerUsersCount ?? 0), 0)
            newUnfollowerUsersCount = max(Int(oldUserDetail?.followerUsersCount ?? 0) - Int(followerUsersCount), 0)
        }

        return (newFollowerUsersCount, newUnfollowerUsersCount)
    }
}
