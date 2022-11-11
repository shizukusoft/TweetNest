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
import AsyncAlgorithms

extension Session {
    private func newBackgroundContext() -> NSManagedObjectContext {
        let context = self.persistentContainer.newBackgroundContext()
        context.undoManager = nil

        return context
    }
}

extension Session {
    public typealias UserDetailChanges = (oldUserDetailObjectID: NSManagedObjectID?, newUserDetailObjectID: NSManagedObjectID?)

    @discardableResult
    public func updateAllUsers() async throws -> [NSManagedObjectID: Result<UserDetailChanges, Error>] {
        let managedObjectContext = newBackgroundContext()

        let accountObjectIDs: [NSManagedObjectID] = try await managedObjectContext.perform {
            let fetchRequest = NSFetchRequest<NSManagedObjectID>(entityName: ManagedAccount.entity().name!)
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(keyPath: \ManagedAccount.preferringSortOrder, ascending: true),
                NSSortDescriptor(keyPath: \ManagedAccount.creationDate, ascending: false),
            ]
            fetchRequest.resultType = .managedObjectIDResultType

            return try managedObjectContext.fetch(fetchRequest)
        }

        return await updateUsers(for: accountObjectIDs, managedObjectContext: managedObjectContext)
    }

    @discardableResult
    public func updateUsers(
        for accountManagedObjectIDs: some Collection<NSManagedObjectID>,
        managedObjectContext _managedObjectContext: NSManagedObjectContext? = nil
    ) async -> [NSManagedObjectID: Result<UserDetailChanges, Error>] {
        let managedObjectContext = _managedObjectContext ?? newBackgroundContext()

        return await withTaskGroup(
            of: (NSManagedObjectID, Result<UserDetailChanges, Error>?, [UserDataAssetsURLSessionManager.DownloadRequest]).self
        ) { taskGroup in
            accountManagedObjectIDs.forEach { accountManagedObjectID in
                taskGroup.addTask {
                    var userDataAssetDownloadRequests: [UserDataAssetsURLSessionManager.DownloadRequest] = .init()

                    do {
                        let results = try await self.updateUser(
                            accountManagedObjectID: accountManagedObjectID,
                            userDataAssetDownloadRequests: &userDataAssetDownloadRequests,
                            managedObjectContext: managedObjectContext
                        )

                        return (accountManagedObjectID, results.flatMap { .success($0) }, userDataAssetDownloadRequests)
                    } catch {
                        return (accountManagedObjectID, .failure(error), userDataAssetDownloadRequests)
                    }
                }
            }

            var userDataAssetDownloadRequests: [UserDataAssetsURLSessionManager.DownloadRequest] = .init()

            let results = await taskGroup
                .reduce(into: [NSManagedObjectID: Result<UserDetailChanges, Error>]()) { partialResult, element in
                    partialResult[element.0] = element.1

                    userDataAssetDownloadRequests.append(contentsOf: element.2)
                }

            await self.userDataAssetsURLSessionManager.download(userDataAssetDownloadRequests)

            return results
        }
    }

    private func updateUser(
        accountManagedObjectID: NSManagedObjectID,
        userDataAssetDownloadRequests: inout [UserDataAssetsURLSessionManager.DownloadRequest],
        managedObjectContext: NSManagedObjectContext
    ) async throws -> UserDetailChanges? {
        let results = try await updateUsers(
            for: nil,
            accountManagedObjectID: accountManagedObjectID,
            userDataAssetsDownloadRequests: &userDataAssetDownloadRequests,
            managedObjectContext: managedObjectContext
        )

        return results.first?.value
    }

    @discardableResult
    public func updateUsers(
        for userIDs: some Collection<Twitter.User.ID>,
        accountManagedObjectID: NSManagedObjectID,
        managedObjectContext _managedObjectContext: NSManagedObjectContext? = nil
    ) async throws -> [Twitter.User.ID: UserDetailChanges] {
        guard !userIDs.isEmpty else {
            return [:]
        }

        let managedObjectContext = _managedObjectContext ?? newBackgroundContext()

        var userDataAssetsDownloadRequests: [UserDataAssetsURLSessionManager.DownloadRequest] = .init()

        do {
            let results = try await updateUsers(
                for: Set(userIDs),
                accountManagedObjectID: accountManagedObjectID,
                userDataAssetsDownloadRequests: &userDataAssetsDownloadRequests,
                managedObjectContext: managedObjectContext
            )

            await self.userDataAssetsURLSessionManager.download(userDataAssetsDownloadRequests)

            return results
        } catch {
            await self.userDataAssetsURLSessionManager.download(userDataAssetsDownloadRequests)

            throw error
        }
    }
}

extension Session {
    @discardableResult
    private func updateUsers(
        for userIDs: Set<Twitter.User.ID>?,
        accountManagedObjectID: NSManagedObjectID,
        userDataAssetsDownloadRequests: inout [UserDataAssetsURLSessionManager.DownloadRequest],
        managedObjectContext: NSManagedObjectContext
    ) async throws -> [Twitter.User.ID: UserDetailChanges] {
        let (accountUserID, accountPreferences) = try await withExtendedBackgroundExecution {
            try await managedObjectContext.perform {
                guard let account = managedObjectContext.object(with: accountManagedObjectID) as? ManagedAccount else {
                    throw SessionError.unknown
                }

                return (account.userID, account.preferences)
            }
        }

        guard let accountUserID = accountUserID else {
            try await updateUserID(
                accountManagedObjectID: accountManagedObjectID,
                managedObjectContext: managedObjectContext
            )

            return try await updateUsers(
                for: userIDs,
                accountManagedObjectID: accountManagedObjectID,
                userDataAssetsDownloadRequests: &userDataAssetsDownloadRequests,
                managedObjectContext: managedObjectContext
            )
        }

        let userIDs = userIDs ?? [accountUserID]

        guard !userIDs.isEmpty else {
            return [:]
        }

        let twitterSession = try await self.twitterSession(for: accountManagedObjectID)

        let userObjectIDsByUserID = try await Self.preflightUsersForUpdating(
            userIDs: userIDs,
            accountUserID: accountUserID,
            context: managedObjectContext
        )

        let chunkedUserIDs = userObjectIDsByUserID.keys.chunks(ofCount: 100)

        return try await withThrowingTaskGroup(
            of: ([TwitterV1.User], [Twitter.User.ID: AdditionalUserInfo], ClosedRange<Date>).self
        ) { taskGroup in
            for userIDs in chunkedUserIDs {
                taskGroup.addTask {
                    try await withExtendedBackgroundExecution {
                        let fetchStartDate = Date()

                        async let additionalUserInfos = Self.fetchAdditionalUserInfos(
                            for: userIDs,
                            accountUserID: accountUserID,
                            accountPreferences: accountPreferences,
                            twitterSession: twitterSession
                        )

                        let users: [TwitterV1.User]
                        if chunkedUserIDs.count == 1 && userIDs.count == 1 {
                            users = try await [TwitterV1.User(id: userIDs[userIDs.startIndex], session: twitterSession)]
                        } else {
                            users = try await TwitterV1.User.users(ids: Array(userIDs), session: twitterSession)
                        }

                        return try await (users, additionalUserInfos, fetchStartDate...Date())
                    }
                }
            }

            return try await taskGroup
                .map { element in
                    let results = try await self.updateUsers(
                        element.0,
                        usersFetchDates: element.2,
                        userObjectIDsByUserID: userObjectIDsByUserID,
                        addtionalUserInfos: element.1,
                        context: managedObjectContext
                    )

                    let relatedUserIDs = Set(
                        element.1
                            .lazy
                            .filter {
                                $0.key == accountUserID
                            }
                            .flatMap {
                                $0.value.relatedUserIDs
                            }
                    )

                    return (results, relatedUserIDs)
                }
                .reduce(into: [Twitter.User.ID: UserDetailChanges]()) { totalResults, chunkedResults in
                    chunkedResults.0.0.forEach { totalResults[$0.0] = $0.1 }

                    userDataAssetsDownloadRequests.append(contentsOf: chunkedResults.0.1)

                    _ = try await updateUsers(
                        for: chunkedResults.1.subtracting([accountUserID]),
                        accountManagedObjectID: accountManagedObjectID,
                        userDataAssetsDownloadRequests: &userDataAssetsDownloadRequests,
                        managedObjectContext: managedObjectContext
                    )
                }
        }
    }
}

extension Session {
    @discardableResult
    private func updateUserID(
        accountManagedObjectID: NSManagedObjectID,
        managedObjectContext: NSManagedObjectContext
    ) async throws -> Twitter.User.ID {
        let twitterSession = try await self.twitterSession(for: accountManagedObjectID)
        let accountUser = try await TwitterV1.User.me(session: twitterSession)

        return try await managedObjectContext.perform(schedule: .immediate) {
            guard let account = managedObjectContext.object(with: accountManagedObjectID) as? ManagedAccount else {
                throw SessionError.unknown
            }

            if account.userID == nil {
                account.userID = String(accountUser.id)
            }

            if managedObjectContext.hasChanges {
                try managedObjectContext.save()
            }

            return account.userID ?? String(accountUser.id)
        }
    }

    private static func preflightUsersForUpdating<S>(
        userIDs: S,
        accountUserID: String,
        context: NSManagedObjectContext
    ) async throws -> [Twitter.User.ID: NSManagedObjectID] where S: Sequence, S.Element == Twitter.User.ID {
        try await withExtendedBackgroundExecution {
            try await context.perform { [userIDs = Set(userIDs)] in
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

                            user.lastUpdateStartDate = Date()

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

        var relatedUserIDs: Set<Twitter.User.ID> {
            Set(
                [
                    followingUserIDs,
                    followerIDs,
                    blockingUserIDs,
                    mutingUserIDs
                ].compacted().joined()
            )
        }
    }

    private static func fetchAdditionalUserInfos(
        for userIDs: some Sequence<Twitter.User.ID>,
        accountUserID: Twitter.User.ID,
        accountPreferences: ManagedAccount.Preferences,
        twitterSession: Twitter.Session
    ) async throws -> [Twitter.User.ID: AdditionalUserInfo] {
        try await withThrowingTaskGroup(
            of: (Twitter.User.ID, AdditionalUserInfo?).self
        ) { taskGroup in
            for userID in userIDs {
                taskGroup.addTask {
                    guard userID == accountUserID else {
                        return (userID, nil)
                    }

                    async let followingUserIDs = Twitter.User.followingUserIDs(forUserID: accountUserID, session: twitterSession).userIDs
                    async let followerIDs = Twitter.User.followerIDs(forUserID: accountUserID, session: twitterSession).userIDs
                    async let myBlockingUserIDs = accountPreferences.fetchBlockingUsers ?
                        Twitter.User.myBlockingUserIDs(session: twitterSession).userIDs : nil
                    async let myMutingUserIDs = accountPreferences.fetchMutingUsers ?
                        Twitter.User.myMutingUserIDs(session: twitterSession).userIDs : nil

                    return (
                        userID,
                        try await AdditionalUserInfo(
                            followingUserIDs: followingUserIDs,
                            followerIDs: followerIDs,
                            blockingUserIDs: myBlockingUserIDs,
                            mutingUserIDs: myMutingUserIDs
                        )
                    )
                }
            }

            return try await taskGroup.reduce(into: [:]) { partialResult, element in
                guard let additionalUserInfo = element.1 else {
                    return
                }

                partialResult[element.0] = additionalUserInfo
            }
        }
    }
}

extension Session {
    private static func previousUserDetail(
        for userID: Twitter.User.ID,
        managedObjectContext: NSManagedObjectContext
    ) throws -> ManagedUserDetail? {
        let previousUserDetailFetchRequest = ManagedUserDetail.fetchRequest()
        previousUserDetailFetchRequest.predicate = NSPredicate(format: "userID == %@", userID)
        previousUserDetailFetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \ManagedUserDetail.creationDate, ascending: false)
        ]
        previousUserDetailFetchRequest.fetchLimit = 1
        previousUserDetailFetchRequest.returnsObjectsAsFaults = false

        return try managedObjectContext.fetch(previousUserDetailFetchRequest).first
    }

    private static func downloadRequests(for twitterUser: TwitterV1.User) -> some Collection<UserDataAssetsURLSessionManager.DownloadRequest> {
        [
            twitterUser.profileImageOriginalURL.flatMap {
                UserDataAssetsURLSessionManager.DownloadRequest(
                    url: $0,
                    priority: URLSessionTask.defaultPriority,
                    expectsToReceiveFileSize: 1 * 1024 * 1024
                )
            },
            twitterUser.profileBannerOriginalURL.flatMap {
                UserDataAssetsURLSessionManager.DownloadRequest(
                    url: $0,
                    priority: URLSessionTask.lowPriority,
                    expectsToReceiveFileSize: 5 * 1024 * 1024
                )
            },
        ].compacted()
    }

    private static func updateLastUpdateDates(
        for userManagedObjectID: some Sequence<NSManagedObjectID>,
        usersFetchDates: ClosedRange<Date>,
        managedObjectContext: NSManagedObjectContext
    ) throws {
        let userFetchRequest = ManagedUser.fetchRequest()
        userFetchRequest.predicate = NSPredicate(format: "SELF IN %@", Array(userManagedObjectID))
        userFetchRequest.returnsObjectsAsFaults = false

        let users = try managedObjectContext.fetch(userFetchRequest)

        for user in users {
            user.lastUpdateStartDate = usersFetchDates.lowerBound
            user.lastUpdateEndDate = usersFetchDates.upperBound
        }
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
                            let previousUserDetail = try Self.previousUserDetail(for: userID, managedObjectContext: chunkedUsersProcessingContext)

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

                        let downloadRequests = Self.downloadRequests(for: twitterUser)

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

                        try Self.updateLastUpdateDates(
                            for: results.0.lazy.compactMap { userObjectIDsByUserID[$0.0] },
                            usersFetchDates: usersFetchDates,
                            managedObjectContext: context
                        )

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
