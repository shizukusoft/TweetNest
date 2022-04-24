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
import SwiftUI

extension Session {
    public typealias UserDetailChanges = (oldUserDetailObjectID: NSManagedObjectID?, newUserDetailObjectID: NSManagedObjectID?)?
    public typealias UserUpdateResult = Result<UserDetailChanges, Error>

    @discardableResult
    public func updateUsers<S>(
        ids userIDs: S,
        accountObjectID: NSManagedObjectID,
        context: NSManagedObjectContext? = nil
    ) async throws -> [Twitter.User.ID: UserUpdateResult] where S: Sequence, S.Element == Twitter.User.ID {
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

        var updatingUsersResult = [Twitter.User.ID: UserUpdateResult]()

        if userIDs.contains(accountUserID) {
            do {
                updatingUsersResult[accountUserID] = try await .success(updateUser(accountObjectID: accountObjectID, context: context))
            } catch {
                updatingUsersResult[accountUserID] = .failure(error)
            }
        }

        let twitterSession = try await self.twitterSession(for: accountObjectID)

        for (key, value) in try await updateUsers(ids: userIDs.subtracting([accountUserID]), accountUserID: accountUserID, twitterSession: twitterSession, context: context) {
            updatingUsersResult[key] = value
        }

        return updatingUsersResult
    }

    @discardableResult
    public func updateUser(
        accountObjectID: NSManagedObjectID,
        context: NSManagedObjectContext?
    ) async throws -> UserDetailChanges {
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

        async let updatingAccountUserResult = updateUsers(
            ids: [accountUserID],
            accountUserID: accountUserID,
            twitterSession: twitterSession,
            followingUserIDs: followingUserIDs,
            followerIDs: followerIDs,
            myBlockingUserIDs: myBlockingUserIDs,
            myMutingUserIDs: myMutingUserIDs,
            context: context
        )

        _ = try await self.updateUsers(
            ids: Set<Twitter.User.ID>([followingUserIDs, followerIDs, myBlockingUserIDs, myMutingUserIDs].compacted().joined()),
            accountUserID: accountUserID,
            twitterSession: twitterSession,
            context: context
        )

        return try await updatingAccountUserResult[accountUserID]?.get()
    }

    private func updateUsers<S>(
        ids userIDs: S,
        accountUserID: Twitter.User.ID,
        twitterSession: Twitter.Session,
        followingUserIDs: [Twitter.User.ID]? = nil,
        followerIDs: [Twitter.User.ID]? = nil,
        myBlockingUserIDs: [Twitter.User.ID]? = nil,
        myMutingUserIDs: [Twitter.User.ID]? = nil,
        context: NSManagedObjectContext
    ) async throws -> [Twitter.User.ID: UserUpdateResult] where S: Sequence, S.Element == Twitter.User.ID {
        try await withThrowingTaskGroup(of: (Date, (users: [Twitter.User], errors: [TwitterServerError])).self) { chunkedUsersFetchTaskGroup in
            async let _refinedUserObjectIDByID: [Twitter.User.ID: NSManagedObjectID?] = context.perform { [userIDs = Set(userIDs)] in
                let accountUserIDsfetchRequest = NSFetchRequest<NSDictionary>()
                accountUserIDsfetchRequest.entity = Account.entity()
                accountUserIDsfetchRequest.resultType = .dictionaryResultType
                accountUserIDsfetchRequest.propertiesToFetch = ["userID"]
                accountUserIDsfetchRequest.returnsDistinctResults = true

                let results = try context.fetch(accountUserIDsfetchRequest)
                let otherAccountUserIDs = Set(
                    results.compactMap {
                        $0["userID"] as? Twitter.User.ID
                    }
                ).subtracting([accountUserID])

                // Don't update user data if user has account. (Might overwrite followings/followers list)
                let userIDs = userIDs.subtracting(otherAccountUserIDs)

                let userFetchRequest: NSFetchRequest<User> = User.fetchRequest()
                userFetchRequest.predicate = NSCompoundPredicate(
                    andPredicateWithSubpredicates: [
                        NSPredicate(format: "id IN %@", userIDs)
                    ]
                )
                userFetchRequest.sortDescriptors = [
                    NSSortDescriptor(keyPath: \User.modificationDate, ascending: false),
                    NSSortDescriptor(keyPath: \User.creationDate, ascending: false)
                ]
                userFetchRequest.relationshipKeyPathsForPrefetching = ["accounts"]
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

            async let _preferences = ManagedPreferences.Preferences(for: context)

            try Task.checkCancellation()

            let refinedUserObjectIDByID = try await _refinedUserObjectIDByID

            try Task.checkCancellation()

            for chunkecUserIDs in refinedUserObjectIDByID.keys.chunks(ofCount: 100) {
                chunkedUsersFetchTaskGroup.addTask {
                    try await withExtendedBackgroundExecution {
                        try await (Date(), Twitter.User.users(ids: Array(chunkecUserIDs), session: twitterSession))
                    }
                }
            }

            try Task.checkCancellation()

            let preferences = await _preferences

            return try await withThrowingTaskGroup(
                of: [(Twitter.User.ID, UserUpdateResult)].self
            ) { chunkedUsersProcessingTaskGroup in
                for try await chunkedUsers in chunkedUsersFetchTaskGroup {
                    let chunkedUsersFetchedDate = Date()

                    chunkedUsersProcessingTaskGroup.addTask {
                        let chunkedUsersProcessingContext = NSManagedObjectContext(.privateQueue)
                        chunkedUsersProcessingContext.parent = context
                        chunkedUsersProcessingContext.automaticallyMergesChangesFromParent = true
                        chunkedUsersProcessingContext.undoManager = nil

                        let results = try await withThrowingTaskGroup(
                            of: (Twitter.User.ID, UserUpdateResult).self,
                            returning: [(Twitter.User.ID, UserUpdateResult)].self
                        ) { userProcessingTaskGroup in
                            for twitterUser in chunkedUsers.1.users {
                                userProcessingTaskGroup.addTask {
                                    async let _profileBanner = preferences.fetchProfileHeaderImages == true ? withExtendedBackgroundExecution { try await twitterUser.profileBanner(session: twitterSession) } : nil

                                    try Task.checkCancellation()

                                    let profileHeaderImageURL = try await _profileBanner?.sizes.max(by: { $0.value.width < $1.value.width })?.value.url

                                    if let profileImageOriginalURL = twitterUser.profileImageOriginalURL {
                                        self.dataAssetsURLSessionManager.download(profileImageOriginalURL)
                                    }

                                    if let profileHeaderImageURL = profileHeaderImageURL {
                                        self.dataAssetsURLSessionManager.download(profileHeaderImageURL)
                                    }

                                    try Task.checkCancellation()

                                    let userDetailObjectIDs: (NSManagedObjectID?, NSManagedObjectID?) = try await chunkedUsersProcessingContext.perform(schedule: .enqueued) {
                                        let userObjectID = refinedUserObjectIDByID[twitterUser.id] as? NSManagedObjectID
                                        let user = userObjectID.flatMap { chunkedUsersProcessingContext.object(with: $0) as? User }
                                        let previousUserDetail = user?.sortedUserDetails?.last

                                        let userDetail = try UserDetail.createOrUpdate(
                                            twitterUser: twitterUser,
                                            profileHeaderImageURL: profileHeaderImageURL,
                                            followingUserIDs: followingUserIDs,
                                            followerUserIDs: followerIDs,
                                            blockingUserIDs: myBlockingUserIDs,
                                            mutingUserIDs: myMutingUserIDs,
                                            userUpdateStartDate: chunkedUsers.0,
                                            userDetailCreationDate: chunkedUsersFetchedDate,
                                            previousUserDetail: previousUserDetail,
                                            context: chunkedUsersProcessingContext
                                        )

                                        return (previousUserDetail?.objectID, userDetail.objectID)
                                    }

                                    return (twitterUser.id, .success(userDetailObjectIDs))
                                }
                            }

                            for twitterError in chunkedUsers.1.errors {
                                userProcessingTaskGroup.addTask {
                                    Logger(subsystem: Bundle.tweetNestKit.bundleIdentifier!, category: "fetch-user")
                                        .error("Error occurred while fetch user: \(twitterError as NSError, privacy: .public)")

                                    guard let value = twitterError.value else {
                                        throw twitterError
                                    }

                                    return (value, .failure(twitterError))
                                }
                            }


                            return try await userProcessingTaskGroup.reduce(into: [], { $0.append($1) })
                        }

                        try await chunkedUsersProcessingContext.perform {
                            try context.performAndWait {
                                if chunkedUsersProcessingContext.hasChanges {
                                    try chunkedUsersProcessingContext.save()
                                }

                                if context.hasChanges {
                                    try withExtendedBackgroundExecution {
                                        try context.save()
                                    }
                                }
                            }
                        }

                        return results
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
