//
//  Session+UpdateUser.swift
//  Session+UpdateUser
//
//  Created by Jaehong Kang on 2021/08/06.
//

import Foundation
import CoreData
import OrderedCollections
import UnifiedLogging
import Twitter
import SwiftUI

extension Session {
    @discardableResult
    func updateUsers<C>(ids userIDs: C, with twitterSession: Twitter.Session) async throws -> [NSManagedObjectID] where C: Collection, C.Index == Int, C.Element == Twitter.User.ID {
        let userIDs = OrderedSet(userIDs)

        return try await withThrowingTaskGroup(of: (Date, [Twitter.User], Date).self) { chunkedUsersTaskGroup in
            for chunkedUserIDs in userIDs.chunked(into: 100) {
                chunkedUsersTaskGroup.addTask {
                    let startDate = Date()
                    let users = try await [Twitter.User](ids: chunkedUserIDs, session: twitterSession)
                    let endDate = Date()

                    return (startDate, users, endDate)
                }
            }

            return try await withThrowingTaskGroup(of: (Twitter.User.ID, NSManagedObjectID?).self) { objectIDsForUserIDTaskGroup in
                let context = container.newBackgroundContext()
                context.undoManager = nil

                for try await chunkedUsers in chunkedUsersTaskGroup {
                    for user in chunkedUsers.1 {
                        objectIDsForUserIDTaskGroup.addTask {
                            let userObjectIDForUserID: (Twitter.User.ID, NSManagedObjectID?) = try await context.perform {
                                let userData = try UserData.createOrUpdate(
                                    twitterUser: user,
                                    userUpdateStartDate: chunkedUsers.0,
                                    userDataCreationDate: chunkedUsers.2,
                                    context: context
                                )
                                let userObjectID = userData.user?.objectID

                                if userData.user?.account != nil {
                                    // Don't update user data if user data has account. (Might overwrite followings/followers list)
                                    context.delete(userData)
                                }

                                if context.hasChanges {
                                    try context.save()
                                }

                                return (user.id, userObjectID)
                            }

                            do {
                                _ = try await DataAsset.dataAsset(for: user.profileImageOriginalURL, session: self, context: context)

                                try await context.perform {
                                    if context.hasChanges {
                                        try context.save()
                                    }
                                }
                            } catch {
                                Logger(subsystem: Bundle.module.bundleIdentifier!, category: "fetch-profile-image")
                                    .error("Error occurred while downloading image: \(String(reflecting: error), privacy: .public)")
                            }

                            return userObjectIDForUserID
                        }
                    }
                }

                return try await objectIDsForUserIDTaskGroup
                    .reduce(into: []) { $0.append($1) }
                    .sorted(by: { userIDs.firstIndex(of: $0.0) ?? -1 < userIDs.firstIndex(of: $1.0) ?? -1 })
                    .compactMap { $0.1 }
            }
        }
    }

    @discardableResult
    public func updateUser(forAccountObjectID accountObjectID: NSManagedObjectID) async throws -> Bool {
        try await Task.detached { // FIXME: Code using Task may deadlock in some circumstances. (80688213)
            let context = self.container.newBackgroundContext()
            context.undoManager = nil

            let accountID = await context.perform {
                (context.object(with: accountObjectID) as? Account)?.id
            }

            guard let accountID = accountID else {
                throw SessionError.unknown
            }

            let userID = String(accountID)

            let twitterSession = try await self.twitterSession(for: accountID)

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

            async let _twitterUser = Twitter.User(id: userID, session: twitterSession)
            async let _followingUserIDs = Twitter.User.followingUserIDs(forUserID: userID, session: twitterSession)
            async let _followerIDs = Twitter.User.followerIDs(forUserID: userID, session: twitterSession)
            async let _myBlockingUserIDs = Twitter.User.myBlockingUserIDs(session: twitterSession)

            let twitterUser = try await _twitterUser
            async let _profileImageDataAsset = DataAsset.dataAsset(for: twitterUser.profileImageOriginalURL, session: self, context: context)

            let followingUserIDs = try await _followingUserIDs
            let followerIDs = try await _followerIDs
            let myBlockingUserIDs = try await _myBlockingUserIDs
            let twitterUserFetchDate = Date()

            try await self.updateUsers(ids: OrderedSet(followingUserIDs + followerIDs + myBlockingUserIDs), with: twitterSession)

            _ = try await _profileImageDataAsset

            let hasChanges: Bool = try await context.perform {
                let account = context.object(with: accountObjectID) as? Account

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

                userData.user?.account = account

                try context.save()

                return previousUserData?.objectID != userData.objectID
            }

            return hasChanges
        }.value
    }
}
