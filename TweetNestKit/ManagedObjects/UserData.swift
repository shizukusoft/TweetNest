//
//  UserData.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/02/26.
//
//

import Foundation
import CoreData
import Twitter

@objc(TWNKUserData)
public class UserData: NSManagedObject, Identifiable {
    
}

extension UserData {
    @discardableResult
    static func createOrUpdate(
        twitterUser: Twitter.User,
        followingUserIDs: [String]? = nil,
        followerUserIDs: [String]? = nil,
        blockingUserIDs: [String]? = nil,
        profileImageData: Data? = nil,
        userUpdateStartDate: Date = Date(),
        userUpdateEndDate: Date = Date(),
        userDataCreationDate: Date = Date(),
        context: NSManagedObjectContext
    ) throws -> UserData {
        try context.performAndWait {
            let userFetchRequest: NSFetchRequest<User> = User.fetchRequest()
            userFetchRequest.predicate = NSPredicate(format: "id == %@", twitterUser.id)
            userFetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

            let user = try context.fetch(userFetchRequest).first ?? {
                let user = User(context: context)
                user.id = twitterUser.id
                user.creationDate = userDataCreationDate

                return user
            }()

            user.lastUpdateStartDate = userUpdateStartDate
            user.lastUpdateEndDate = userUpdateEndDate

            if
                let lastUserData = user.sortedUserDatas?.last,

                lastUserData.blockingUserIDs == blockingUserIDs,
                lastUserData.followingUserIDs == followingUserIDs,
                lastUserData.followerUserIDs == followerUserIDs,

                lastUserData.followersCount == twitterUser.publicMetrics.followersCount,
                lastUserData.followingUsersCount == twitterUser.publicMetrics.followingUsersCount,
                lastUserData.isProtected == twitterUser.protected,
                lastUserData.isVerified == twitterUser.verified,
                lastUserData.listedCount == twitterUser.publicMetrics.listedCount,
                lastUserData.location == twitterUser.location,
                lastUserData.name == twitterUser.name,
                lastUserData.profileImageURL == twitterUser.profileImageOriginalURL,
                lastUserData.profileImageData == profileImageData,
                lastUserData.tweetsCount == twitterUser.publicMetrics.tweetsCount,
                lastUserData.url == twitterUser.expandedURL,
                lastUserData.userCreationDate == twitterUser.createdAt,
                lastUserData.userAttributedDescription == twitterUser.attributedDescription.flatMap({ NSAttributedString($0) }),
                lastUserData.username == twitterUser.username,
                lastUserData.user == user
            {
                return lastUserData
            } else {
                let newUserData = UserData(context: context)
                newUserData.creationDate = userDataCreationDate
                
                newUserData.blockingUserIDs = blockingUserIDs
                newUserData.followingUserIDs = followingUserIDs
                newUserData.followerUserIDs = followerUserIDs

                newUserData.followersCount = Int32(twitterUser.publicMetrics.followersCount)
                newUserData.followingUsersCount = Int32(twitterUser.publicMetrics.followingUsersCount)
                newUserData.isProtected = twitterUser.protected
                newUserData.isVerified = twitterUser.verified
                newUserData.listedCount = Int32(twitterUser.publicMetrics.listedCount)
                newUserData.location = twitterUser.location
                newUserData.name = twitterUser.name
                newUserData.profileImageURL = twitterUser.profileImageOriginalURL
                newUserData.profileImageData = profileImageData
                newUserData.tweetsCount = Int32(twitterUser.publicMetrics.tweetsCount)
                newUserData.url = twitterUser.expandedURL
                newUserData.userCreationDate = twitterUser.createdAt
                newUserData.userAttributedDescription = twitterUser.attributedDescription.flatMap({ NSAttributedString($0) })
                newUserData.username = twitterUser.username
                newUserData.user = user

                newUserData.user?.modificationDate = userDataCreationDate

                return newUserData
            }
        }
    }
}
