//
//  Session+UpdateAccount.swift
//  TweetNestKit
//
//  Created by Jaehong Kang on 2021/08/03.
//

import Foundation
import CoreData
import Twitter

extension Session {
    @discardableResult
    public func updateAccount(_ accountObjectID: NSManagedObjectID) async throws -> Bool {
        let context = container.newBackgroundContext()

        guard let account = try await context.perform({
            try context.existingObject(with: accountObjectID) as? Account
        }) else {
            throw SessionError.unknown
        }

        let twitterSession = try await twitterSession(for: account.id)

        let twitterAccount = try await Twitter.Account.me(session: twitterSession)
        let twitterUser = try await Twitter.User(id: String(twitterAccount.id), session: twitterSession)
        let twitterUserFetchDate = Date()

        let profileImageDataTask = Task {
            try await Self.urlData(from: twitterUser.profileImageOriginalURL)
        }

        let followingUserIDsTask = Task { () -> [String] in
            let followings = try await twitterUser.followings(session: twitterSession)
            let followingsFetchDate = Date()

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
                            creationDate: followingsFetchDate,
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
            let followers = try await twitterUser.followers(session: twitterSession)
            let followersFetchDate = Date()

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
                            creationDate: followersFetchDate,
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
            let previousUserData = account.user?.sortedUserDatas?.last

            let userData = try UserData.createOrUpdate(
                twitterUser: twitterUser,
                followingUserIDs: followingUserIDs,
                followerUserIDs: followerUserIDs,
                profileImageData: profileImageData,
                creationDate: twitterUserFetchDate,
                context: context
            )
            userData.user?.account = account

            try context.save()

            return previousUserData?.objectID != userData.objectID
        }
    }

    @discardableResult
    public func updateAccount(_ account: Account) async throws -> Bool {
        try await updateAccount(account.objectID)
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
