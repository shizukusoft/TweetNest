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

        let followingUserIDs = try await twitterUser.followingUserIDs(session: twitterSession)
        let followerIDs = try await twitterUser.followerIDs(session: twitterSession)
        let myBlockingUserIDs = try await Twitter.User.myBlockingUserIDs(session: twitterSession)

        let usersLookupTask = Task.detached {
            let context = self.container.newBackgroundContext()
            let userIDs = Set(followingUserIDs + followerIDs + myBlockingUserIDs)

            let users: [Twitter.User] = try await withThrowingTaskGroup(of: [Twitter.User].self) { taskGroup in
                Array(userIDs)
                    .chunked(into: 100)
                    .enumerated()
                    .forEach { element in
                        taskGroup.addTask {
                            let startDate = Date()
                            let users = try await [Twitter.User](ids: element.element, session: twitterSession)
                            let endDate = Date()

                            for user in users {
                                try await context.perform(schedule: .enqueued) {
                                    try autoreleasepool {
                                        let userData = try UserData.createOrUpdate(
                                            twitterUser: user,
                                            userUpdateStartDate: startDate,
                                            userDataCreationDate: endDate,
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

                            return users
                        }
                    }

                return try await taskGroup
                    .reduce(into: [[Twitter.User]]()) {
                        $0.append($1)
                    }
                    .flatMap { $0 }
            }

            let profileImageOriginalURLs = Set([twitterUser.profileImageOriginalURL] + users.map(\.profileImageOriginalURL))

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
                followingUserIDs: followingUserIDs,
                followerUserIDs: followerIDs,
                blockingUserIDs: myBlockingUserIDs,
                userUpdateStartDate: updateStartDate,
                userDataCreationDate: twitterUserFetchDate,
                context: context
            )

            try context.save()

            return (userObjectID: userData.user!.objectID, hasChanges: previousUserData?.objectID != userData.objectID)
        }

        try await usersLookupTask.value

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
