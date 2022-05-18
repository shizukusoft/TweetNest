//
//  Session+Updates.swift
//  TweetNestKit
//
//  Created by 강재홍 on 2022/05/18.
//

import Foundation
import CoreData
import BackgroundTask
import Twitter
import TwitterV1
import UnifiedLogging

extension Session {
    @discardableResult
    public func updateAllAccounts() async throws -> [(NSManagedObjectID, Result<Bool, Swift.Error>)] {
        let context = persistentContainer.newBackgroundContext()
        context.undoManager = nil

        let accountObjectIDs: [NSManagedObjectID] = try await context.perform {
            let fetchRequest = NSFetchRequest<NSManagedObjectID>(entityName: ManagedAccount.entity().name!)
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(keyPath: \ManagedAccount.preferringSortOrder, ascending: true),
                NSSortDescriptor(keyPath: \ManagedAccount.creationDate, ascending: false),
            ]
            fetchRequest.resultType = .managedObjectIDResultType

            return try context.fetch(fetchRequest)
        }

        return await withTaskGroup(of: (NSManagedObjectID, Result<Bool, Swift.Error>).self) { taskGroup in
            accountObjectIDs.forEach { accountObjectID in
                taskGroup.addTask {
                    do {
                        let updateResults = try await self.updateAccount(accountObjectID, context: context)
                        return (accountObjectID, .success(updateResults?.oldUserDetailObjectID != updateResults?.newUserDetailObjectID))
                    } catch {
                        return (accountObjectID, .failure(error))
                    }
                }
            }

            return await taskGroup.reduce(into: [], { $0.append($1) })
        }
    }
}

extension Session {
    public typealias UserDetailChanges = (oldUserDetailObjectID: NSManagedObjectID?, newUserDetailObjectID: NSManagedObjectID?)

    @discardableResult
    public func updateAccount(
        _ accountObjectID: NSManagedObjectID,
        context _context: NSManagedObjectContext? = nil
    ) async throws -> UserDetailChanges? {
        let context = _context ?? {
            let context = self.persistentContainer.newBackgroundContext()
            context.undoManager = nil

            return context
        }()

        let twitterSession = try await self.twitterSession(for: accountObjectID)
        let accountPreferences: ManagedAccount.Preferences = try await context.perform {
            try withExtendedBackgroundExecution {
                guard let account = context.object(with: accountObjectID) as? ManagedAccount else {
                    throw SessionError.unknown
                }

                return account.preferences
            }
        }

        let fetchStartDate = Date()

        async let myBlockingUserIDs = try await withExtendedBackgroundExecution {
            accountPreferences.fetchBlockingUsers ? try await Twitter.User.myBlockingUserIDs(session: twitterSession).userIDs : nil
        }

        async let myMutingUserIDs = try await withExtendedBackgroundExecution {
            accountPreferences.fetchMutingUsers ? try await Twitter.User.myMutingUserIDs(session: twitterSession).userIDs : nil
        }

        let accountUser = try await withExtendedBackgroundExecution {
            try await TwitterV1.User.me(session: twitterSession)
        }

        let accountUserID = String(accountUser.id)

        async let userObjectIDsByUserID = preflightUsersForUpdating(userIDs: [accountUserID], accountUserID: accountUserID, updateStartDate: fetchStartDate, context: context)
        async let updateAccount: Void = context.perform(schedule: .enqueued) {
            try withExtendedBackgroundExecution {
                guard let account = context.object(with: accountObjectID) as? ManagedAccount else {
                    return
                }

                guard account.userID != accountUserID else {
                    return
                }

                account.userID = accountUserID

                try context.save()
            }
        }

        async let followingUserIDs = try await withExtendedBackgroundExecution {
            try await Twitter.User.followingUserIDs(forUserID: accountUserID, session: twitterSession).userIDs
        }

        async let followerIDs = try await withExtendedBackgroundExecution {
            try await Twitter.User.followerIDs(forUserID: accountUserID, session: twitterSession).userIDs
        }

        let additionalAccountUserInfo = try await AdditionalUserInfo(
            followingUserIDs: followingUserIDs,
            followerIDs: followerIDs,
            blockingUserIDs: myBlockingUserIDs,
            mutingUserIDs: myMutingUserIDs
        )

        let fetchEndDate = Date()

        let accountUserDetailChanges = try await updateUsers(
            [accountUser],
            usersFetchDates: fetchStartDate...fetchEndDate,
            userObjectIDsByUserID: userObjectIDsByUserID,
            addtionalUserInfos: [
                accountUserID: additionalAccountUserInfo
            ],
            context: context
        )

        _ = try await updateAccount

        async let updateOtherUsers = self.updateUsers(
            ids: Set<Twitter.User.ID>(
                [
                    additionalAccountUserInfo.followingUserIDs,
                    additionalAccountUserInfo.followerIDs,
                    additionalAccountUserInfo.blockingUserIDs,
                    additionalAccountUserInfo.mutingUserIDs
                ].compacted().joined()
            ),
            accountObjectID: accountObjectID,
            context: context
        )

        await self.userDataAssetsURLSessionManager.download(accountUserDetailChanges.1)

        _ = try await updateOtherUsers

        return accountUserDetailChanges.0.first?.1
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
            guard let account = context.object(with: accountObjectID) as? ManagedAccount else {
                throw SessionError.unknown
            }

            return account.userID
        }

        guard let accountUserID = accountUserID else {
            throw SessionError.unknown
        }

        async let accountUpdateResult = userIDs.contains(accountUserID) ? updateAccount(accountObjectID, context: context) : nil

        var updatingUsersResult = try await withThrowingTaskGroup(
            of: ([TwitterV1.User], ClosedRange<Date>).self,
            returning: [Twitter.User.ID: UserDetailChanges].self
        ) { [userIDs = userIDs.subtracting([accountUserID])] chunkedUsersFetchTaskGroup in
            let userObjectIDsByUserID = try await preflightUsersForUpdating(userIDs: userIDs, accountUserID: accountUserID, context: context)
            let twitterSession = try await self.twitterSession(for: accountObjectID)

            for chunkedUserIDs in userObjectIDsByUserID.keys.chunks(ofCount: 100) {
                chunkedUsersFetchTaskGroup.addTask {
                    let fetchStartDate = Date()

                    let users: [TwitterV1.User] = try await withExtendedBackgroundExecution {
                        if userObjectIDsByUserID.count == 1 && chunkedUserIDs.count == 1 {
                            return try await [TwitterV1.User(id: chunkedUserIDs[chunkedUserIDs.startIndex], session: twitterSession)]
                        } else {
                            return try await TwitterV1.User.users(ids: Array(chunkedUserIDs), session: twitterSession)
                        }
                    }

                    let fetchEndDate = Date()

                    return (users, fetchStartDate...fetchEndDate)
                }
            }

            return try await withThrowingTaskGroup(
                of: ([(Twitter.User.ID, UserDetailChanges)], [UserDataAssetsURLSessionManager.DownloadRequest]).self
            ) { chunkedUsersProcessingTaskGroup in
                for try await chunkedUsers in chunkedUsersFetchTaskGroup {
                    chunkedUsersProcessingTaskGroup.addTask {
                        try await self.updateUsers(chunkedUsers.0, usersFetchDates: chunkedUsers.1, userObjectIDsByUserID: userObjectIDsByUserID, context: context)
                    }
                }

                var dataAssetsDownloadRequests = Set<UserDataAssetsURLSessionManager.DownloadRequest>()
                do {
                    let results = try await chunkedUsersProcessingTaskGroup.reduce(into: [Twitter.User.ID: UserDetailChanges]()) { totalResults, chunkedResults in
                        chunkedResults.0.forEach {
                            totalResults[$0.0] = $0.1
                        }

                        dataAssetsDownloadRequests.formUnion(chunkedResults.1)
                    }

                    await self.userDataAssetsURLSessionManager.download(dataAssetsDownloadRequests)

                    return results
                } catch {
                    await self.userDataAssetsURLSessionManager.download(dataAssetsDownloadRequests)

                    throw error
                }
            }
        }

        updatingUsersResult[accountUserID] = try await accountUpdateResult

        return updatingUsersResult
    }
}

extension Session {
    private func preflightUsersForUpdating<S>(
        userIDs: S,
        accountUserID: String,
        updateStartDate: Date? = nil,
        context: NSManagedObjectContext
    ) async throws -> [Twitter.User.ID: NSManagedObjectID] where S: Sequence, S.Element == Twitter.User.ID {
        try await context.perform { [userIDs = Set(userIDs)] in
            try withExtendedBackgroundExecution {
                let accountUserIDsfetchRequest = NSFetchRequest<NSDictionary>()
                accountUserIDsfetchRequest.entity = ManagedAccount.entity()
                accountUserIDsfetchRequest.resultType = .dictionaryResultType
                accountUserIDsfetchRequest.propertiesToFetch = ["userID"]
                accountUserIDsfetchRequest.returnsDistinctResults = true

                let results = try context.fetch(accountUserIDsfetchRequest)
                let allAccountUserIDs = Set(
                    results.compactMap {
                        $0["userID"] as? Twitter.User.ID
                    }
                )

                let userFetchRequest = ManagedUser.fetchRequest()
                userFetchRequest.predicate = NSPredicate(format: "id IN %@", userIDs)
                userFetchRequest.sortDescriptors = [
                    NSSortDescriptor(keyPath: \ManagedUser.creationDate, ascending: false)
                ]
                userFetchRequest.propertiesToFetch = ["id", "lastUpdateStartDate"]
                userFetchRequest.returnsObjectsAsFaults = false

                let users = try context.fetch(userFetchRequest)
                let usersByID = Dictionary(
                    users.lazy.map { ($0.id, $0) },
                    uniquingKeysWith: { first, _ in first }
                )

                let refinedUsersByUserID: [Twitter.User.ID: ManagedUser] = Dictionary(
                    uniqueKeysWithValues: userIDs
                        .lazy
                        .compactMap { userID in
                            let user = usersByID[userID] ?? {
                                let user = ManagedUser(context: context)
                                user.id = userID
                                user.creationDate = Date()

                                return user
                            }()

                            guard (user.lastUpdateStartDate ?? .distantPast) < Date(timeIntervalSinceNow: -60) else {
                                return nil
                            }

                            // Don't update user data if user has account. (Might overwrite followings/followers list)
                            guard userID == accountUserID || allAccountUserIDs.contains(userID) == false else {
                                return nil
                            }

                            user.lastUpdateStartDate = updateStartDate ?? Date()

                            return (userID, user)
                        }
                )

                if context.hasChanges {
                    try context.save()
                }

                return refinedUsersByUserID.mapValues {
                    $0.objectID
                }
            }
        }
    }
}

extension Session {
    private struct AdditionalUserInfo {
        let followingUserIDs: [Twitter.User.ID]?
        let followerIDs: [Twitter.User.ID]?
        let blockingUserIDs: [Twitter.User.ID]?
        let mutingUserIDs: [Twitter.User.ID]?
    }

    private func updateUsers(
        _ users: [TwitterV1.User],
        usersFetchDates: ClosedRange<Date>,
        userObjectIDsByUserID: [Twitter.User.ID: NSManagedObjectID],
        addtionalUserInfos: [Twitter.User.ID: AdditionalUserInfo] = [:],
        context: NSManagedObjectContext
    ) async throws -> ([(Twitter.User.ID, UserDetailChanges)], [UserDataAssetsURLSessionManager.DownloadRequest]) {
        try await withExtendedBackgroundExecution {
            let chunkedUsersProcessingContext = NSManagedObjectContext(.privateQueue)
            chunkedUsersProcessingContext.parent = context
            chunkedUsersProcessingContext.automaticallyMergesChangesFromParent = true
            chunkedUsersProcessingContext.undoManager = nil

            let results = try await withThrowingTaskGroup(
                of: (Twitter.User.ID, UserDetailChanges, [UserDataAssetsURLSessionManager.DownloadRequest]).self,
                returning: ([(Twitter.User.ID, UserDetailChanges)], [UserDataAssetsURLSessionManager.DownloadRequest]).self
            ) { userProcessingTaskGroup in
                for twitterUser in users {
                    let userID = String(twitterUser.id)

                    userProcessingTaskGroup.addTask {
                        async let userDetailChanges: UserDetailChanges = chunkedUsersProcessingContext.perform(schedule: .enqueued) {
                            let previousUserDetailFetchRequest = ManagedUserDetail.fetchRequest()
                            previousUserDetailFetchRequest.predicate = NSPredicate(format: "userID == %@", userID)
                            previousUserDetailFetchRequest.sortDescriptors = [
                                NSSortDescriptor(keyPath: \ManagedUserDetail.creationDate, ascending: false)
                            ]
                            previousUserDetailFetchRequest.fetchLimit = 1
                            previousUserDetailFetchRequest.returnsObjectsAsFaults = false

                            let previousUserDetail = try chunkedUsersProcessingContext.fetch(previousUserDetailFetchRequest).first

                            let userDetail = try ManagedUserDetail.createOrUpdate(
                                twitterUser: twitterUser,
                                followingUserIDs: addtionalUserInfos[userID]?.followingUserIDs,
                                followerUserIDs: addtionalUserInfos[userID]?.followerIDs,
                                blockingUserIDs: addtionalUserInfos[userID]?.blockingUserIDs,
                                mutingUserIDs: addtionalUserInfos[userID]?.mutingUserIDs,
                                creationDate: usersFetchDates.upperBound,
                                previousUserDetail: previousUserDetail,
                                context: chunkedUsersProcessingContext
                            )

                            return (previousUserDetail?.objectID, userDetail.objectID)
                        }

                        let downloadRequests = [
                            twitterUser.profileImageOriginalURL.flatMap {
                                UserDataAssetsURLSessionManager.DownloadRequest(url: $0, priority: URLSessionTask.defaultPriority, expectsToReceiveFileSize: 1 * 1024 * 1024)
                            },
                            twitterUser.profileBannerOriginalURL.flatMap {
                                UserDataAssetsURLSessionManager.DownloadRequest(url: $0, priority: URLSessionTask.lowPriority, expectsToReceiveFileSize: 5 * 1024 * 1024)
                            },
                        ].compacted()

                        return try await (userID, userDetailChanges, Array(downloadRequests))
                    }
                }

                return try await userProcessingTaskGroup.reduce(
                    into: ([(Twitter.User.ID, UserDetailChanges)](), [UserDataAssetsURLSessionManager.DownloadRequest]())
                ) { partialResult, element in
                    partialResult.0.append((element.0, element.1))
                    partialResult.1.append(contentsOf: element.2)
                }
            }

            try await chunkedUsersProcessingContext.perform(schedule: .enqueued) {
                try context.performAndWait {
                    try autoreleasepool {
                        if chunkedUsersProcessingContext.hasChanges {
                            try chunkedUsersProcessingContext.save()
                        }

                        let userFetchRequest = ManagedUser.fetchRequest()
                        userFetchRequest.predicate = NSPredicate(format: "SELF IN %@", results.0.compactMap { userObjectIDsByUserID[$0.0] })
                        userFetchRequest.returnsObjectsAsFaults = false

                        let users = try context.fetch(userFetchRequest)

                        for user in users {
                            user.lastUpdateEndDate = Date()
                        }

                        if context.hasChanges {
                            try context.save()
                        }
                    }
                }
            }

            return results
        }
    }
}
