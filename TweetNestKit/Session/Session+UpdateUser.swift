//
//  Session+UpdateUser.swift
//  Session+UpdateUser
//
//  Created by Jaehong Kang on 2021/08/06.
//

import Foundation
import Algorithms
import BackgroundTask
import CoreData
import OrderedCollections
import UnifiedLogging
import Twitter
import TwitterV1
import SwiftUI

extension Session {
    public typealias UserDetailChanges = (oldUserDetailObjectID: NSManagedObjectID?, newUserDetailObjectID: NSManagedObjectID?)

    private struct AdditionalUserInfo {
        let followingUserIDs: [Twitter.User.ID]?
        let followerIDs: [Twitter.User.ID]?
        let blockingUserIDs: [Twitter.User.ID]?
        let mutingUserIDs: [Twitter.User.ID]?
    }

    @discardableResult
    public func updateUsers<S>(
        ids userIDs: S,
        accountObjectID: NSManagedObjectID,
        context: NSManagedObjectContext? = nil
    ) async throws -> [Twitter.User.ID: UserDetailChanges] where S: Sequence, S.Element == Twitter.User.ID {
        let context = context ?? {
            let context = self.persistentContainer.newBackgroundContext()
            context.undoManager = nil

            return context
        }()

        let userIDs = Set(userIDs)

        let accountUserID: Twitter.User.ID? = try await context.perform {
            guard let account = context.object(with: accountObjectID) as? Account else {
                throw SessionError.unknown
            }

            return account.userID
        }

        guard let accountUserID = accountUserID else {
            throw SessionError.unknown
        }

        async let accountUpdateResult = userIDs.contains(accountUserID) ? updateUser(accountObjectID: accountObjectID, context: context) : nil

        let twitterSession = try await self.twitterSession(for: accountObjectID)
        var updatingUsersResult = try await updateUsers(ids: userIDs.subtracting([accountUserID]), accountUserID: accountUserID, twitterSession: twitterSession, context: context)

        updatingUsersResult[accountUserID] = try await accountUpdateResult

        return updatingUsersResult
    }

    @discardableResult
    public func updateUser(
        accountObjectID: NSManagedObjectID,
        context: NSManagedObjectContext?
    ) async throws -> UserDetailChanges? {
        let context = context ?? {
            let context = self.persistentContainer.newBackgroundContext()
            context.undoManager = nil

            return context
        }()

        let (accountPreferences, accountUserID) = try await context.perform { () -> (Account.Preferences, Twitter.User.ID?) in
            guard let account = context.object(with: accountObjectID) as? Account else {
                throw SessionError.unknown
            }

            return (account.preferences, account.userID)
        }

        guard let accountUserID = accountUserID else {
            throw SessionError.unknown
        }

        let twitterSession = try await self.twitterSession(for: accountObjectID)

        async let _followingUserIDs = withExtendedBackgroundExecution { try await Twitter.User.followingUserIDs(forUserID: accountUserID, session: twitterSession).userIDs }
        async let _followerIDs = withExtendedBackgroundExecution { try await Twitter.User.followerIDs(forUserID: accountUserID, session: twitterSession).userIDs }
        async let _myBlockingUserIDs = accountPreferences.fetchBlockingUsers ? withExtendedBackgroundExecution { try await Twitter.User.myBlockingUserIDs(session: twitterSession).userIDs } : nil
        async let _myMutingUserIDs = accountPreferences.fetchMutingUsers ? withExtendedBackgroundExecution { try await Twitter.User.myMutingUserIDs(session: twitterSession).userIDs } : nil

        let followingUserIDs = try await _followingUserIDs
        let followerIDs = try await _followerIDs
        let myBlockingUserIDs = try await _myBlockingUserIDs
        let myMutingUserIDs = try await _myMutingUserIDs

        return try await self.updateUsers(
            ids: Set<Twitter.User.ID>([accountUserID] + [followingUserIDs, followerIDs, myBlockingUserIDs, myMutingUserIDs].compacted().joined()),
            accountUserID: accountUserID,
            twitterSession: twitterSession,
            addtionalUserInfos: [
                accountUserID: AdditionalUserInfo(
                    followingUserIDs: followingUserIDs,
                    followerIDs: followerIDs,
                    blockingUserIDs: myBlockingUserIDs,
                    mutingUserIDs: myMutingUserIDs
                )
            ],
            context: context
        )[accountUserID]
    }

    private func updateUsers<S>(
        ids userIDs: S,
        accountUserID: Twitter.User.ID,
        twitterSession: Twitter.Session,
        addtionalUserInfos: [Twitter.User.ID: AdditionalUserInfo] = [:],
        context: NSManagedObjectContext
    ) async throws -> [Twitter.User.ID: UserDetailChanges] where S: Sequence, S.Element == Twitter.User.ID {
        try await withThrowingTaskGroup(of: (Date, [TwitterV1.User]).self) { chunkedUsersFetchTaskGroup in
            async let _refinedUserObjectIDByID: [Twitter.User.ID: NSManagedObjectID?] = context.perform { [userIDs = Set(userIDs)] in
                let accountUserIDsfetchRequest = NSFetchRequest<NSDictionary>()
                accountUserIDsfetchRequest.entity = Account.entity()
                accountUserIDsfetchRequest.resultType = .dictionaryResultType
                accountUserIDsfetchRequest.propertiesToFetch = ["userID"]
                accountUserIDsfetchRequest.returnsDistinctResults = true

                let results = try context.fetch(accountUserIDsfetchRequest)
                let allAccountUserIDs = Set(
                    results.compactMap {
                        $0["userID"] as? Twitter.User.ID
                    }
                )

                let userFetchRequest: NSFetchRequest<User> = User.fetchRequest()
                userFetchRequest.predicate = NSPredicate(format: "id IN %@", userIDs)
                userFetchRequest.sortDescriptors = [
                    NSSortDescriptor(keyPath: \User.modificationDate, ascending: false),
                    NSSortDescriptor(keyPath: \User.creationDate, ascending: false)
                ]
                userFetchRequest.returnsObjectsAsFaults = false

                let users = try context.fetch(userFetchRequest)
                let usersByID = Dictionary(uniqueKeysWithValues: users.lazy.uniqued(on: \.id).map { ($0.id, $0) })

                let refinedUserObjectIDByID: [Twitter.User.ID: NSManagedObjectID?] = Dictionary(
                    uniqueKeysWithValues: userIDs
                        .lazy
                        .compactMap {
                            let user = usersByID[$0]
                            let lastUpdateStartDate = user?.lastUpdateStartDate ?? .distantPast

                            guard lastUpdateStartDate.addingTimeInterval(60) < Date() else {
                                return nil
                            }

                            // Don't update user data if user has account. (Might overwrite followings/followers list)
                            guard $0 == accountUserID || allAccountUserIDs.contains($0) == false else {
                                return nil
                            }

                            user?.lastUpdateStartDate = Date()

                            return ($0, user?.objectID)
                        }
                )

                if context.hasChanges {
                    context.perform {
                        withExtendedBackgroundExecution {
                            do {
                                try context.save()
                            } catch {
                                Logger(label: Bundle.tweetNestKit.bundleIdentifier!, category: String(reflecting: Self.self))
                                    .error("\(error as NSError, privacy: .public)")
                            }
                        }
                    }
                }

                return refinedUserObjectIDByID
            }

            try Task.checkCancellation()

            let refinedUserObjectIDByID = try await _refinedUserObjectIDByID

            try Task.checkCancellation()

            if refinedUserObjectIDByID.count == 1 {
                chunkedUsersFetchTaskGroup.addTask {
                    try await withExtendedBackgroundExecution {
                        try await (Date(), [TwitterV1.User(id: refinedUserObjectIDByID[refinedUserObjectIDByID.startIndex].key, session: twitterSession)])
                    }
                }
            } else {
                for chunkecUserIDs in refinedUserObjectIDByID.keys.chunks(ofCount: 100) {
                    chunkedUsersFetchTaskGroup.addTask {
                        try await withExtendedBackgroundExecution {
                            try await (Date(), TwitterV1.User.users(ids: Array(chunkecUserIDs), session: twitterSession))
                        }
                    }
                }
            }

            try Task.checkCancellation()

            return try await withThrowingTaskGroup(
                of: [(Twitter.User.ID, UserDetailChanges)].self
            ) { chunkedUsersProcessingTaskGroup in
                for try await chunkedUsers in chunkedUsersFetchTaskGroup {
                    let chunkedUsersFetchedDate = Date()

                    chunkedUsersProcessingTaskGroup.addTask {
                        let chunkedUsersProcessingContext = NSManagedObjectContext(.privateQueue)
                        chunkedUsersProcessingContext.parent = context
                        chunkedUsersProcessingContext.automaticallyMergesChangesFromParent = true
                        chunkedUsersProcessingContext.undoManager = nil

                        let results = try await withThrowingTaskGroup(
                            of: (Twitter.User.ID, UserDetailChanges, [URLSessionTask]).self,
                            returning: [(Twitter.User.ID, UserDetailChanges, [URLSessionTask])].self
                        ) { userProcessingTaskGroup in
                            for twitterUser in chunkedUsers.1 {
                                let userID = String(twitterUser.id)

                                userProcessingTaskGroup.addTask {
                                    (
                                        userID,
                                        try await chunkedUsersProcessingContext.perform(schedule: .enqueued) {
                                            let prefetchedUserObjectID = refinedUserObjectIDByID[String(twitterUser.id)] as? NSManagedObjectID
                                            let prefetchedUser = prefetchedUserObjectID.flatMap { chunkedUsersProcessingContext.object(with: $0) as? User }

                                            let user = try prefetchedUser ?? {
                                                let userFetchRequest: NSFetchRequest<User> = User.fetchRequest()
                                                userFetchRequest.predicate = NSPredicate(format: "id == %@", String(twitterUser.id))
                                                userFetchRequest.sortDescriptors = [
                                                    NSSortDescriptor(keyPath: \User.modificationDate, ascending: false),
                                                    NSSortDescriptor(keyPath: \User.creationDate, ascending: false)
                                                ]
                                                userFetchRequest.fetchLimit = 1
                                                userFetchRequest.returnsObjectsAsFaults = false

                                                if let user = try chunkedUsersProcessingContext.fetch(userFetchRequest).first {
                                                    return user
                                                } else {
                                                    let userObjectID: NSManagedObjectID = context.performAndWait {
                                                        let user = User(context: context)
                                                        user.id = String(twitterUser.id)
                                                        user.creationDate = chunkedUsersFetchedDate

                                                        return user.objectID
                                                    }

                                                    guard let user = chunkedUsersProcessingContext.object(with: userObjectID) as? User else {
                                                        fatalError()
                                                    }

                                                    return user
                                                }
                                            }()

                                            let previousUserDetail = user.sortedUserDetails?.last

                                            let userDetail = try UserDetail.createOrUpdate(
                                                twitterUser: twitterUser,
                                                followingUserIDs: addtionalUserInfos[userID]?.followingUserIDs,
                                                followerUserIDs: addtionalUserInfos[userID]?.followerIDs,
                                                blockingUserIDs: addtionalUserInfos[userID]?.blockingUserIDs,
                                                mutingUserIDs: addtionalUserInfos[userID]?.mutingUserIDs,
                                                creationDate: chunkedUsersFetchedDate,
                                                user: user,
                                                context: chunkedUsersProcessingContext
                                            )

                                            user.lastUpdateStartDate = chunkedUsers.0
                                            user.lastUpdateEndDate = Date()

                                            return (previousUserDetail?.objectID, userDetail.objectID)
                                        },
                                        Array(
                                            [
                                                twitterUser.profileImageOriginalURL.flatMap {
                                                    self.dataAssetsURLSessionManager.download($0, priority: URLSessionTask.defaultPriority, expectsToReceiveFileSize: 1 * 1024 * 1024)
                                                },
                                                twitterUser.profileBannerOriginalURL.flatMap {
                                                    self.dataAssetsURLSessionManager.download($0, priority: URLSessionTask.lowPriority, expectsToReceiveFileSize: 5 * 1024 * 1024)
                                                }
                                            ].compacted()
                                        )
                                    )
                                }
                            }

                            return try await userProcessingTaskGroup.reduce(into: [], { $0.append($1) })
                        }

                        let chunkedUsersProcessingContextHasChanges: Bool = try await chunkedUsersProcessingContext.perform(schedule: .enqueued) {
                            guard chunkedUsersProcessingContext.hasChanges else {
                                return false
                            }

                            try chunkedUsersProcessingContext.save()
                            return true
                        }

                        if chunkedUsersProcessingContextHasChanges {
                            try await context.perform(schedule: .enqueued) {
                                if context.hasChanges {
                                    try withExtendedBackgroundExecution {
                                        try context.save()
                                    }
                                }
                            }
                        }

                        return results.map { userResult in
                            Task.detached(priority: .utility) {
                                userResult.2.forEach {
                                    $0.resume()
                                }
                            }

                            return (userResult.0, userResult.1)
                        }
                    }
                }

                return try await chunkedUsersProcessingTaskGroup.reduce(into: [:]) { totalResults, chunkedUsersResults in
                    chunkedUsersResults.forEach {
                        totalResults[$0.0] = $0.1
                    }
                }
            }
        }
    }
}
