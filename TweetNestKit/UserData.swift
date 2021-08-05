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
        profileImageData: Data? = nil,
        creationDate: Date = Date(),
        context: NSManagedObjectContext
    ) throws -> UserData {
        try context.performAndWait {
            let userFetchRequest: NSFetchRequest<User> = User.fetchRequest()
            userFetchRequest.predicate = NSPredicate(format: "id == %@", twitterUser.id)
            userFetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

            let user = try context.fetch(userFetchRequest).first ?? {
                let user = User(context: context)
                user.id = twitterUser.id
                user.creationDate = creationDate

                return user
            }()

            if
                let lastUserData = user.sortedUserDatas?.last,
                lastUserData.followingUserIDs == followingUserIDs,
                lastUserData.followerUserIDs == followerUserIDs,
                lastUserData.isProtected == twitterUser.protected,
                lastUserData.isVerified == twitterUser.verified,
                lastUserData.location == twitterUser.location,
                lastUserData.name == twitterUser.name,
                lastUserData.profileImageURL == twitterUser.profileImageOriginalURL,
                lastUserData.profileImageData == profileImageData,
                lastUserData.url == twitterUser.expandedURL,
                lastUserData.userCreationDate == twitterUser.createdAt,
                lastUserData.userAttributedDescription == twitterUser.attributedDescription.flatMap({ NSAttributedString($0) }),
                lastUserData.username == twitterUser.username,
                lastUserData.user == user
            {
                return lastUserData
            } else {
                let newUserData = UserData(context: context)
                newUserData.creationDate = creationDate

                newUserData.followingUserIDs = followingUserIDs
                newUserData.followerUserIDs = followerUserIDs
                newUserData.isProtected = twitterUser.protected
                newUserData.isVerified = twitterUser.verified
                newUserData.location = twitterUser.location
                newUserData.name = twitterUser.name
                newUserData.profileImageURL = twitterUser.profileImageOriginalURL
                newUserData.profileImageData = profileImageData
                newUserData.url = twitterUser.expandedURL
                newUserData.userCreationDate = twitterUser.createdAt
                newUserData.userAttributedDescription = twitterUser.attributedDescription.flatMap({ NSAttributedString($0) })
                newUserData.username = twitterUser.username
                newUserData.user = user

                newUserData.user?.modificationDate = creationDate

                return newUserData
            }
        }
    }
}
