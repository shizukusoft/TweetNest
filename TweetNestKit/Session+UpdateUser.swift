//
//  Session+UpdateUser.swift
//  Session+UpdateUser
//
//  Created by Jaehong Kang on 2021/08/06.
//

import Foundation
import CoreData
import UnifiedLogging
import Twitter

extension Session {
    @discardableResult
    func updateUser(id userID: Twitter.User.ID, with twitterSession: Twitter.Session) async throws -> (userObjectID: NSManagedObjectID, hasChanges: Bool) {
        let context = container.newBackgroundContext()
        context.undoManager = nil

        let updateStartDate = Date()
        try await context.perform {
            let fetchRequest = User.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", userID)

            guard let user = try context.fetch(fetchRequest).last else {
                return
            }

            user.lastUpdateStartDate = updateStartDate
            user.lastUpdateEndDate = nil

            try context.save()
        }

        let twitterUser = try await Twitter.User(id: userID, session: twitterSession)
        let twitterUserFetchDate = Date()

        let followingUsersTask = Task.detached { () -> [Twitter.User] in
            let followingUsersFetchStartDate = Date()
            let followingUsers = try await twitterUser.followingUsers(session: twitterSession).map { try $0.get() }
            let followingUsersFetchEndDate = Date()

            for followingUser in followingUsers {
                try await context.perform(schedule: .enqueued) {
                    try autoreleasepool {
                        let userData = try UserData.createOrUpdate(
                            twitterUser: followingUser,
                            userUpdateStartDate: followingUsersFetchStartDate,
                            userDataCreationDate: followingUsersFetchEndDate,
                            context: context
                        )

                        if userData.user?.account != nil {
                            // Don't update user data if user data has account. (Might overwrite followings/followers list)
                            context.delete(userData)
                        }

                        try context.save()
                    }
                }
            }

            return followingUsers
        }

        let followersTask = Task.detached { () -> [Twitter.User] in
            let followersFetchStartDate = Date()
            let followers = try await twitterUser.followers(session: twitterSession).map { try $0.get() }
            let followersFetchEndDate = Date()

            for follower in followers {
                try await context.perform(schedule: .enqueued) {
                    try autoreleasepool {
                        let userData = try UserData.createOrUpdate(
                            twitterUser: follower,
                            userUpdateStartDate: followersFetchStartDate,
                            userDataCreationDate: followersFetchEndDate,
                            context: context
                        )

                        if userData.user?.account != nil {
                            // Don't update user data if user data has account. (Might overwrite followings/followers list)
                            context.delete(userData)
                        }

                        try context.save()
                    }
                }
            }

            return followers
        }

        let blockingUsersTask = Task.detached { () -> [Twitter.User] in
            let blockingUsersFetchStartDate = Date()
            let blockingUserIDs = try await Twitter.Account.myBlockingIDs(session: twitterSession)
            let blockingUsers: [Twitter.User] = try await withThrowingTaskGroup(of: (Int, [Twitter.User]).self) { taskGroup in
                blockingUserIDs
                    .chunked(into: 100)
                    .enumerated()
                    .forEach { element in
                        taskGroup.addTask {
                            (element.offset, try await [Twitter.User](ids: element.element, session: twitterSession))
                        }
                    }

                return try await taskGroup
                    .reduce(into: [(Int, [Twitter.User])]()) {
                        $0.append($1)
                    }
                    .sorted(by: { $0.0 < $1.0 })
                    .flatMap { $0.1 }
            }
            let blockingUsersFetchEndDate = Date()

            for blockingUser in blockingUsers {
                try await context.perform(schedule: .enqueued) {
                    try autoreleasepool {
                        let userData = try UserData.createOrUpdate(
                            twitterUser: blockingUser,
                            userUpdateStartDate: blockingUsersFetchStartDate,
                            userDataCreationDate: blockingUsersFetchEndDate,
                            context: context
                        )

                        if userData.user?.account != nil {
                            // Don't update user data if user data has account. (Might overwrite followings/followers list)
                            context.delete(userData)
                        }

                        try context.save()
                    }
                }
            }

            return blockingUsers
        }

        let followingUsers = try await followingUsersTask.value
        let followers = try await followersTask.value
        let blockingUsers = try await blockingUsersTask.value

        let profileImageDownloadTask = Task.detached {
            let context = self.container.newBackgroundContext()
            let profileImageOriginalURLs = Set([twitterUser.profileImageOriginalURL] + followingUsers.map(\.profileImageOriginalURL) + followers.map(\.profileImageOriginalURL) + blockingUsers.map(\.profileImageOriginalURL))

            try await withThrowingTaskGroup(of: Void.self) { taskGroup in
                for profileImageOriginalURL in profileImageOriginalURLs {
                    taskGroup.addTask {
                        do {
                            _ = try await DataAsset.dataAsset(for: profileImageOriginalURL, context: context)
                        } catch {
                            Logger(subsystem: Bundle.module.bundleIdentifier!, category: "fetch-profile-image")
                                .error("Error occurred while downloading image: \(String(reflecting: error), privacy: .public)")
                        }

                        try await context.perform {
                            try context.save()
                        }
                    }
                }

                try await taskGroup.waitForAll()
            }
        }

        let result: (userObjectID: NSManagedObjectID, hasChanges: Bool) = try await context.perform {
            let fetchRequest = User.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", userID)
            fetchRequest.relationshipKeyPathsForPrefetching = ["userDatas"]

            let user = try context.fetch(fetchRequest).last
            let previousUserData = user?.sortedUserDatas?.last

            let userData = try UserData.createOrUpdate(
                twitterUser: twitterUser,
                followingUserIDs: followingUsers.map(\.id),
                followerUserIDs: followers.map(\.id),
                blockingUserIDs: blockingUsers.map(\.id),
                userUpdateStartDate: updateStartDate,
                userDataCreationDate: twitterUserFetchDate,
                context: context
            )

            try context.save()

            return (userObjectID: userData.user!.objectID, hasChanges: previousUserData?.objectID != userData.objectID)
        }

        try await profileImageDownloadTask.value

        return result
    }

    @discardableResult
    public func updateUser(forAccountObjectID accountObjectID: NSManagedObjectID) async throws -> Bool {
        let context = container.newBackgroundContext()

        let accountID = await context.perform {
            (context.object(with: accountObjectID) as? Account)?.id
        }

        guard let accountID = accountID else {
            throw SessionError.unknown
        }

        let twitterSession = try await twitterSession(for: accountID)

        let updateResult = try await updateUser(id: String(accountID), with: twitterSession)

        try await context.perform {
            let user = context.object(with: updateResult.userObjectID) as? User
            let account = context.object(with: accountObjectID) as? Account

            user?.account = account

            try context.save()
        }

        return updateResult.hasChanges
    }
}
