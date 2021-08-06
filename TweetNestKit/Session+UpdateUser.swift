//
//  Session+UpdateUser.swift
//  Session+UpdateUser
//
//  Created by Jaehong Kang on 2021/08/06.
//

import Foundation
import CoreData
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
            try await Self.urlData(from: twitterUser.profileImageOriginalURL)
        }

        let followingUserIDsTask = Task { () -> [String] in
            let followingsFetchStartDate = Date()
            let followings = try await twitterUser.followings(session: twitterSession)
            let followingsFetchEndDate = Date()

            return try await withThrowingTaskGroup(of: (index: Int, twitterUser: Twitter.User, profileImageData: Data).self) { taskGroup in
                for (index, following) in followings.enumerated() {
                    taskGroup.addTask {
                        (
                            index: index,
                            twitterUser: following,
                            profileImageData: try await Self.urlData(from: following.profileImageOriginalURL)
                        )
                    }
                }

                var userIDsByIndex = [Int: String?]()

                for try await following in taskGroup {
                    userIDsByIndex[following.index] = try await context.perform(schedule: .enqueued) {
                        let userData = try UserData.createOrUpdate(
                            twitterUser: following.twitterUser,
                            profileImageData: following.profileImageData,
                            userUpdateStartDate: followingsFetchStartDate,
                            userDataCreationDate: followingsFetchEndDate,
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
            let followers = try await twitterUser.followers(session: twitterSession)
            let followersFetchEndDate = Date()

            return try await withThrowingTaskGroup(of: (index: Int, twitterUser: Twitter.User, profileImageData: Data).self) { taskGroup in
                for (index, follower) in followers.enumerated() {
                    taskGroup.addTask {
                        (
                            index: index,
                            twitterUser: follower,
                            profileImageData: try await Self.urlData(from: follower.profileImageOriginalURL)
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

        let followingUserIDs = try await followingUserIDsTask.value
        let followerUserIDs = try await followerUserIDsTask.value
        let profileImageData = try await profileImageDataTask.value

        return try await context.perform {
            let previousUserData = user?.sortedUserDatas?.last

            let userData = try UserData.createOrUpdate(
                twitterUser: twitterUser,
                followingUserIDs: followingUserIDs,
                followerUserIDs: followerUserIDs,
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

        await context.perform {
            let user = context.object(with: updateResult.userObjectID) as? User
            let account = context.object(with: accountObjectID) as? Account

            user?.account = account
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
}
