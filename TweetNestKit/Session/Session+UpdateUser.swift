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
    public nonisolated func updateUsers<C>(
        ids userIDs: C,
        accountObjectID: NSManagedObjectID,
        context: NSManagedObjectContext? = nil
    ) async throws -> [Twitter.User.ID: (oldUserDetailObjectID: NSManagedObjectID?, newUserDetailObjectID: NSManagedObjectID)] where C: Collection, C.Index == Int, C.Element == Twitter.User.ID {
        try await updateUsers(ids: userIDs, accountObjectID: accountObjectID, accountUserID: nil, context: context)
    }

    @discardableResult
    nonisolated func updateUsers<C>(
        ids userIDs: C,
        accountObjectID: NSManagedObjectID,
        accountUserID: String? = nil,
        context _context: NSManagedObjectContext? = nil
    ) async throws -> [Twitter.User.ID: (oldUserDetailObjectID: NSManagedObjectID?, newUserDetailObjectID: NSManagedObjectID)] where C: Collection, C.Index == Int, C.Element == Twitter.User.ID {
        try await withExtendedBackgroundExecution {
            let context = _context ?? self.persistentContainer.newBackgroundContext()
            await context.perform {
                let undoManager = _context.flatMap { _context in _context.performAndWait { _context.undoManager }  }

                context.undoManager = undoManager
            }

            let accountPreferences = try await context.perform { () -> Account.Preferences in
                guard let account = try? context.existingObject(with: accountObjectID) as? Account else {
                    throw SessionError.unknown
                }

                return account.preferences
            }

            let twitterSession = try await self.twitterSession(for: accountObjectID)

            let userIDs = OrderedSet(userIDs)

            return try await withThrowingTaskGroup(of: (Date, [Result<Twitter.User, TwitterServerError>]).self) { chunkedUsersTaskGroup in
                let preupdateContext = self.persistentContainer.newBackgroundContext()

                for chunkedUserIDs in userIDs.chunked(into: 100) {
                    try Task.checkCancellation()

                    chunkedUsersTaskGroup.addTask {
                        let updateStartDate = Date()

                        let userIDs: [Twitter.User.ID] = try await preupdateContext.perform {
                            let userFetchRequest: NSFetchRequest<User> = User.fetchRequest()
                            userFetchRequest.predicate = NSPredicate(format: "id IN %@", chunkedUserIDs)
                            userFetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

                            let users = Dictionary(
                                try preupdateContext.fetch(userFetchRequest).map { ($0.id, $0) },
                                uniquingKeysWith: {
                                    if ($0.creationDate ?? .distantPast) < ($1.creationDate ?? .distantPast) {
                                        return $1
                                    } else {
                                        return $0
                                    }
                                }
                            )

                            let userIDs: [Twitter.User.ID] = chunkedUserIDs.compactMap {
                                guard let user = users[$0], let lastUpdateStartDate = user.lastUpdateStartDate else {
                                    return $0
                                }

                                guard lastUpdateStartDate.addingTimeInterval(60) < Date() else {
                                    return nil
                                }

                                // Don't update user data if user has account. (Might overwrite followings/followers list)
                                guard $0 == accountUserID || user.accounts?.isEmpty != false else {
                                    return nil
                                }

                                user.lastUpdateStartDate = updateStartDate

                                return $0
                            }

                            try preupdateContext.save()

                            return userIDs
                        }

                        guard userIDs.isEmpty == false else {
                            return (updateStartDate, [])
                        }

                        return try await (updateStartDate, Twitter.User.users(ids: userIDs, session: twitterSession))
                    }
                }

                return try await withThrowingTaskGroup(of: (Twitter.User.ID, (oldUserDetailObjectID: NSManagedObjectID?, newUserDetailObjectID: NSManagedObjectID)?).self) { taskGroup in
                    defer {
                        // For cancellation or error occured.
                        context.performAndWait {
                            if context.hasChanges {
                                try? context.save()
                            }
                        }
                    }

                    let dataAssetContext = self.persistentContainer.newBackgroundContext()

                    for try await chunkedUsers in chunkedUsersTaskGroup {
                        for twitterUserResult in chunkedUsers.1 {
                            try Task.checkCancellation()

                            let twitterUser: Twitter.User
                            do {
                                twitterUser = try twitterUserResult.get()
                            } catch {
                                Logger(subsystem: Bundle.tweetNestKit.bundleIdentifier!, category: "fetch-user")
                                    .error("Error occurred while fetch user: \(String(reflecting: error), privacy: .public)")
                                continue
                            }

                            taskGroup.addTask {
                                try Task.checkCancellation()

                                async let _followingUserIDs = twitterUser.id == accountUserID ? Twitter.User.followingUserIDs(forUserID: twitterUser.id, session: twitterSession) : nil
                                async let _followerIDs = twitterUser.id == accountUserID ? Twitter.User.followerIDs(forUserID: twitterUser.id, session: twitterSession) : nil
                                async let _myBlockingUserIDs = twitterUser.id == accountUserID && accountPreferences.fetchBlockingUsers ? Twitter.User.myBlockingUserIDs(session: twitterSession) : nil

                                Task.detached(priority: .utility) {
                                    guard let profileImageOriginalURL = twitterUser.profileImageOriginalURL else { return }

                                    await withExtendedBackgroundExecution {
                                        do {
                                            try Task.checkCancellation()

                                            try await DataAsset.dataAsset(for: profileImageOriginalURL, session: self, context: dataAssetContext) { _ in
                                                if dataAssetContext.hasChanges {
                                                    try dataAssetContext.save()
                                                }
                                            }
                                        } catch {
                                            Logger(subsystem: Bundle.tweetNestKit.bundleIdentifier!, category: "fetch-profile-image")
                                                .error("Error occurred while downloading image: \(String(reflecting: error), privacy: .public)")
                                        }
                                    }
                                }

                                let followingUserIDs = try await _followingUserIDs
                                let followerIDs = try await _followerIDs
                                let myBlockingUserIDs = try await _myBlockingUserIDs
                                let twitterUserFetchDate = Date()

                                try Task.checkCancellation()

                                let userIDs = OrderedSet<Twitter.User.ID>([followingUserIDs, followerIDs, myBlockingUserIDs].flatMap { $0 ?? [] })
                                async let _updatingUsers = self.updateUsers(ids: userIDs, accountObjectID: accountObjectID, context: context)

                                async let userDetailObjectIDs: (NSManagedObjectID?, NSManagedObjectID)? = context.perform(schedule: .enqueued) {
                                    let fetchRequest = User.fetchRequest()
                                    fetchRequest.predicate = NSPredicate(format: "id == %@", twitterUser.id)
                                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                                    fetchRequest.fetchLimit = 1
                                    fetchRequest.relationshipKeyPathsForPrefetching = ["userDetails"]

                                    let user = try context.fetch(fetchRequest).first

                                    let previousUserDetail = user?.sortedUserDetails?.last

                                    // Don't update user data if user has account. (Might overwrite followings/followers list)
                                    guard twitterUser.id == accountUserID || user?.accounts?.isEmpty != false else {
                                        return nil
                                    }

                                    let userDetail = try UserDetail.createOrUpdate(
                                        twitterUser: twitterUser,
                                        followingUserIDs: followingUserIDs,
                                        followerUserIDs: followerIDs,
                                        blockingUserIDs: myBlockingUserIDs,
                                        userUpdateStartDate: chunkedUsers.0,
                                        userDetailCreationDate: twitterUserFetchDate,
                                        context: context
                                    )

                                    return (previousUserDetail?.objectID, userDetail.objectID)
                                }

                                try Task.checkCancellation()
                                try await _ = _updatingUsers

                                try Task.checkCancellation()
                                return try await (twitterUser.id, userDetailObjectIDs)
                            }
                        }
                    }

                    let userDetailObjectIDs = try await taskGroup.reduce(into: [:], { $0[$1.0] = $1.1 })

                    try await context.perform {
                        if context.hasChanges {
                            try context.save()
                        }
                    }

                    return userDetailObjectIDs
                }
            }
        }
    }
}
