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
        
        let newUserDetail = UserDetail(context: context)
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
        lhs.blockingUserIDs == rhs.blockingUserIDs &&
        lhs.followingUserIDs == rhs.followingUserIDs &&
        lhs.followerUserIDs == rhs.followerUserIDs &&
        lhs.followerUsersCount == rhs.followerUsersCount &&
        lhs.followingUsersCount == rhs.followingUsersCount &&
        lhs.isProtected == rhs.isProtected &&
        lhs.isVerified == rhs.isVerified &&
        lhs.listedCount == rhs.listedCount &&
        lhs.location == rhs.location &&
        lhs.name == rhs.name &&
        lhs.profileImageURL == rhs.profileImageURL &&
        lhs.tweetsCount == rhs.tweetsCount &&
        lhs.url == rhs.url &&
        lhs.userCreationDate == rhs.userCreationDate &&
        lhs.userAttributedDescription == rhs.userAttributedDescription &&
        lhs.username == rhs.username
    }
}
