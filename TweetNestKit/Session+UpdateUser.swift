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

        let updateStartDate = Date()
        let user: User? = try await context.perform {
            let fetchRequest = User.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", userID)

            return try context.fetch(fetchRequest).last
        }

        if let user = user {
            try await context.perform {
                user.lastUpdateStartDate = updateStartDate
                user.lastUpdateEndDate = nil

                try context.save()
            }
        }

        let twitterUser = try await Twitter.User(id: userID, session: twitterSession)
        let twitterUserFetchDate = Date()

        let profileImageDataTask = Task {
            await Self.profileImage(from: twitterUser.profileImageOriginalURL)
        }

        let followingUserIDsTask = Task { () -> [String] in
            let followingUsersFetchStartDate = Date()
            let followingUsers = try await twitterUser.followingUsers(session: twitterSession).map { try $0.get() }
            let followingUsersFetchEndDate = Date()

            return try await withThrowingTaskGroup(of: (index: Int, twitterUser: Twitter.User, profileImageData: Data?).self) { taskGroup in
                for (index, followingUser) in followingUsers.enumerated() {
                    taskGroup.addTask {
                        (
                            index: index,
                            twitterUser: followingUser,
                            profileImageData: await Self.profileImage(from: followingUser.profileImageOriginalURL)
                        )
                    }
                }

                var userIDsByIndex = [Int: String?]()

                for try await followingUser in taskGroup {
                    userIDsByIndex[followingUser.index] = try await context.perform(schedule: .enqueued) {
                        let userData = try UserData.createOrUpdate(
                            twitterUser: followingUser.twitterUser,
                            profileImageData: followingUser.profileImageData,
                            userUpdateStartDate: followingUsersFetchStartDate,
                            userDataCreationDate: followingUsersFetchEndDate,
                            context: context
                        )

                        let userID = userData.user?.id

                        if userData.user?.account != nil {
                            // Don't update user data if user data has account. (Might overwrite followings/followers list)
                            context.delete(userData)
                        }

                        try context.save()
                        context.refreshAllObjects()

                        return userID
                    }
                }

                return userIDsByIndex
                    .lazy
                    .sorted { $0.key < $1.key }
                    .compactMap { $0.value }
            }
        }

        let followerUserIDsTask = Task { () -> [String] in
            let followersFetchStartDate = Date()
            let followers = try await twitterUser.followers(session: twitterSession).map { try $0.get() }
            let followersFetchEndDate = Date()

            return try await withThrowingTaskGroup(of: (index: Int, twitterUser: Twitter.User, profileImageData: Data?).self) { taskGroup in
                for (index, follower) in followers.enumerated() {
                    taskGroup.addTask {
                        (
                            index: index,
                            twitterUser: follower,
                            profileImageData: await Self.profileImage(from: follower.profileImageOriginalURL)
                        )
                    }
                }

                var userIDsByIndex = [Int: String?]()

                for try await follower in taskGroup {
                    userIDsByIndex[follower.index] = try await context.perform {
                        let userData = try UserData.createOrUpdate(
                            twitterUser: follower.twitterUser,
                            profileImageData: follower.profileImageData,
                            userUpdateStartDate: followersFetchStartDate,
                            userDataCreationDate: followersFetchEndDate,
                            context: context
                        )

                        let userID = userData.user?.id

                        if userData.user?.account != nil {
                            // Don't update user data if user data has account. (Might overwrite followings/followers list)
                            context.delete(userData)
                        }

                        try context.save()
                        context.refreshAllObjects()

                        return userID
                    }
                }

                return userIDsByIndex
                    .lazy
                    .sorted { $0.key < $1.key }
                    .compactMap { $0.value }
            }
        }

        let blockingUserIDsTask = Task { () -> [String] in
            let blockingUsersFetchStartDate = Date()
            let blockingUsers = try await twitterUser.blockingUsers(session: twitterSession).map { try $0.get() }
            let blockingUsersFetchEndDate = Date()

            return try await withThrowingTaskGroup(of: (index: Int, twitterUser: Twitter.User, profileImageData: Data?).self) { taskGroup in
                for (index, blockingUser) in blockingUsers.enumerated() {
                    taskGroup.addTask {
                        (
                            index: index,
                            twitterUser: blockingUser,
                            profileImageData: await Self.profileImage(from: blockingUser.profileImageOriginalURL)
                        )
                    }
                }

                var userIDsByIndex = [Int: String?]()

                for try await blockingUser in taskGroup {
                    userIDsByIndex[blockingUser.index] = try await context.perform {
                        let userData = try UserData.createOrUpdate(
                            twitterUser: blockingUser.twitterUser,
                            profileImageData: blockingUser.profileImageData,
                            userUpdateStartDate: blockingUsersFetchStartDate,
                            userDataCreationDate: blockingUsersFetchEndDate,
                            context: context
                        )

                        let userID = userData.user?.id

                        if userData.user?.account != nil {
                            // Don't update user data if user data has account. (Might overwrite followings/followers list)
                            context.delete(userData)
                        }

                        try context.save()
                        context.refreshAllObjects()

                        return userID
                    }
                }

                return userIDsByIndex
                    .lazy
                    .sorted { $0.key < $1.key }
                    .compactMap { $0.value }
            }
        }

        let followingUserIDs = try await followingUserIDsTask.value
        let followerUserIDs = try await followerUserIDsTask.value
        let blockingUserIDs = try await blockingUserIDsTask.value
        let profileImageData = await profileImageDataTask.value

        return try await context.perform {
            let previousUserData = user?.sortedUserDatas?.last

            let userData = try UserData.createOrUpdate(
                twitterUser: twitterUser,
                followingUserIDs: followingUserIDs,
                followerUserIDs: followerUserIDs,
                blockingUserIDs: blockingUserIDs,
                profileImageData: profileImageData,
                userUpdateStartDate: updateStartDate,
                userDataCreationDate: twitterUserFetchDate,
                context: context
            )

            try context.save()

            return (userObjectID: userData.user!.objectID, hasChanges: previousUserData?.objectID != userData.objectID)
        }
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

extension Session {
    private static func urlData(from url: URL) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard
            let httpResponse = response as? HTTPURLResponse,
            (200..<300).contains(httpResponse.statusCode)
        else {
            throw SessionError.invalidServerResponse
        }

        return data
    }

    private static func profileImage(from url: URL) async -> Data? {
        do {
            return try await urlData(from: url)
        } catch {
            Logger(subsystem: Bundle.module.bundleIdentifier!, category: "fetch-profile-image")
                .error("Error occured while downloading image: \(String(reflecting: error), privacy: .public)")

            return nil
        }
    }
}
