//
//  User.swift
//  TweetNestKit
//
//  Created by Jaehong Kang on 2021/02/25.
//

import Foundation
import CoreData
import TwitterKit

extension User {
    @NSManaged public var userDatas: [UserData]

    static func update(_ twitterUser: TwitterKit.User, context: NSManagedObjectContext) throws -> User {
        let userFetchRequest: NSFetchRequest<User> = User.fetchRequest()
        userFetchRequest.predicate = NSPredicate(format: "id == %d", twitterUser.id)
        userFetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

        let user = try context.fetch(userFetchRequest).first ?? User(context: context)
        user.id = twitterUser.id
        user.creationDate = user.creationDate ?? Date()

        let userDataFetchRequest: NSFetchRequest<UserData> = UserData.fetchRequest()
        userDataFetchRequest.predicate = NSPredicate(format: "id == %d", twitterUser.id)
        userDataFetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

        let userDatas = try context.fetch(userDataFetchRequest)

        let newUserData = UserData(context: context)
        newUserData.id = twitterUser.id
        newUserData.name = twitterUser.name
        newUserData.username = twitterUser.username
        newUserData.profileImageURL = twitterUser.profileImageURL

        if (newUserData == userDatas.last) {
            context.delete(newUserData)
        }

        return user
    }
}
