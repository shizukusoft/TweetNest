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
        followingUserIDs: [String]? = nil,
        followerUserIDs: [String]? = nil,
        blockingUserIDs: [String]? = nil,
        userUpdateStartDate: Date = Date(),
        userUpdateEndDate: Date = Date(),
        userDetailCreationDate: Date = Date(),
        context: NSManagedObjectContext
    ) throws -> UserDetail {
        let userFetchRequest: NSFetchRequest<User> = User.fetchRequest()
        userFetchRequest.predicate = NSPredicate(format: "id == %@", twitterUser.id)
        userFetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        userFetchRequest.relationshipKeyPathsForPrefetching = ["userDetails"]

        let user = try context.fetch(userFetchRequest).last ?? {
            let user = User(context: context)
            user.id = twitterUser.id
            user.creationDate = userDetailCreationDate

            return user
        }()

        user.lastUpdateStartDate = userUpdateStartDate
        user.lastUpdateEndDate = userUpdateEndDate

        if
            let lastUserDetails = user.sortedUserDetails?.last,

            lastUserDetails.blockingUserIDs == blockingUserIDs,
            lastUserDetails.followingUserIDs == followingUserIDs,
            lastUserDetails.followerUserIDs == followerUserIDs,

            lastUserDetails.followerUsersCount == twitterUser.publicMetrics.followersCount,
            lastUserDetails.followingUsersCount == twitterUser.publicMetrics.followingUsersCount,
            lastUserDetails.isProtected == twitterUser.protected,
            lastUserDetails.isVerified == twitterUser.verified,
            lastUserDetails.listedCount == twitterUser.publicMetrics.listedCount,
            lastUserDetails.location == twitterUser.location,
            lastUserDetails.name == twitterUser.name,
            lastUserDetails.profileImageURL == twitterUser.profileImageOriginalURL,
            lastUserDetails.tweetsCount == twitterUser.publicMetrics.tweetsCount,
            lastUserDetails.url == twitterUser.expandedURL,
            lastUserDetails.userCreationDate == twitterUser.createdAt,
            lastUserDetails.userAttributedDescription == twitterUser.attributedDescription.flatMap({ NSAttributedString($0) }),
            lastUserDetails.username == twitterUser.username,
            lastUserDetails.user == user
        {
            return lastUserDetails
        } else {
            let newUserDetail = UserDetail(context: context)
            newUserDetail.creationDate = userDetailCreationDate

            newUserDetail.blockingUserIDs = blockingUserIDs
            newUserDetail.followingUserIDs = followingUserIDs
            newUserDetail.followerUserIDs = followerUserIDs

            newUserDetail.followerUsersCount = Int32(twitterUser.publicMetrics.followersCount)
            newUserDetail.followingUsersCount = Int32(twitterUser.publicMetrics.followingUsersCount)
            newUserDetail.isProtected = twitterUser.protected
            newUserDetail.isVerified = twitterUser.verified
            newUserDetail.listedCount = Int32(twitterUser.publicMetrics.listedCount)
            newUserDetail.location = twitterUser.location
            newUserDetail.name = twitterUser.name
            newUserDetail.profileImageURL = twitterUser.profileImageOriginalURL
            newUserDetail.tweetsCount = Int32(twitterUser.publicMetrics.tweetsCount)
            newUserDetail.url = twitterUser.expandedURL
            newUserDetail.userCreationDate = twitterUser.createdAt
            newUserDetail.userAttributedDescription = twitterUser.attributedDescription.flatMap({ NSAttributedString($0) })
            newUserDetail.username = twitterUser.username
            newUserDetail.user = user

            newUserDetail.user?.modificationDate = userDetailCreationDate

            return newUserDetail
        }
    }
}
