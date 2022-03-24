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
    ) async throws -> [Twitter.User.ID: Result<(oldUserDetailObjectID: NSManagedObjectID?, newUserDetailObjectID: NSManagedObjectID?), TwitterServerError>] where C: Collection, C.Index == Int, C.Element == Twitter.User.ID {
        try await updateUsers(ids: userIDs, accountObjectID: accountObjectID, accountUserID: nil, context: context)
    }

    @discardableResult
    nonisolated func updateUsers<C>(
        ids userIDs: C,
        accountObjectID: NSManagedObjectID,
        accountUserID: String? = nil,
        context _context: NSManagedObjectContext? = nil
    ) async throws -> [Twitter.User.ID: Result<(oldUserDetailObjectID: NSManagedObjectID?, newUserDetailObjectID: NSManagedObjectID?), TwitterServerError>] where C: Collection, C.Index == Int, C.Element == Twitter.User.ID {
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

            return try await withThrowingTaskGroup(of: (Date, (users: [Twitter.User], errors: [TwitterServerError])).self) { chunkedUsersTaskGroup in
                let preupdateContext = self.persistentContainer.newBackgroundContext()

                for chunkedUserIDs in userIDs.chunked(into: 100) {
                    try Task.checkCancellation()

                    chunkedUsersTaskGroup.addTask {
                        let updateStartDate = Date()

                        let userIDs: [Twitter.User.ID] = try await preupdateContext.perform {
                            let userFetchRequest: NSFetchRequest<User> = User.fetchRequest()
                            userFetchRequest.predicate = NSPredicate(format: "id IN %@", chunkedUserIDs)
                            userFetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                            userFetchRequest.returnsObjectsAsFaults = false

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
                            return (updateStartDate, (users: [], errors: []))
                        }

                        return try await (updateStartDate, Twitter.User.users(ids: userIDs, session: twitterSession))
                    }
                }

                return try await withThrowingTaskGroup(of: (Twitter.User.ID, Result<(oldUserDetailObjectID: NSManagedObjectID?, newUserDetailObjectID: NSManagedObjectID?), TwitterServerError>).self) { taskGroup in
                    let dataAssetContext = self.persistentContainer.newBackgroundContext()

                    for try await chunkedUsers in chunkedUsersTaskGroup {
                        for twitterUser in chunkedUsers.1.users {
                            try Task.checkCancellation()

                            taskGroup.addTask {
                                async let _profileBanner = context.performAndWait { self.preferences(for: context).fetchProfileHeaderImages == true } ? twitterUser.profileBanner(session: twitterSession) : nil

                                async let _followingUserIDs = twitterUser.id == accountUserID ? Twitter.User.followingUserIDs(forUserID: twitterUser.id, session: twitterSession).userIDs : nil
                                async let _followerIDs = twitterUser.id == accountUserID ? Twitter.User.followerIDs(forUserID: twitterUser.id, session: twitterSession).userIDs : nil
                                async let _myBlockingUserIDs = twitterUser.id == accountUserID && accountPreferences.fetchBlockingUsers ? Twitter.User.myBlockingUserIDs(session: twitterSession).userIDs : nil
                                async let _myMutingUserIDs = twitterUser.id == accountUserID && accountPreferences.fetchMutingUsers ? Twitter.User.myMutingUserIDs(session: twitterSession).userIDs : nil

                                let profileHeaderImageURL = try await _profileBanner?.sizes.max(by: { $0.value.width < $1.value.width })?.value.url
                                let followingUserIDs = try await _followingUserIDs
                                let followerIDs = try await _followerIDs
                                let myBlockingUserIDs = try await _myBlockingUserIDs
                                let myMutingUserIDs = try await _myMutingUserIDs
                                let twitterUserFetchDate = Date()

                                try Task.checkCancellation()
                                
                                let userIDs = OrderedSet<Twitter.User.ID>([followingUserIDs, followerIDs, myBlockingUserIDs, myMutingUserIDs].flatMap { $0 ?? [] })
                                async let _updatingUsers = self.updateUsers(ids: userIDs, accountObjectID: accountObjectID, context: context)

                                let userDetailObjectIDs: (NSManagedObjectID?, NSManagedObjectID?) = try await context.perform(schedule: .enqueued) {
                                    let fetchRequest = User.fetchRequest()
                                    fetchRequest.predicate = NSPredicate(format: "id == %@", twitterUser.id)
                                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                                    fetchRequest.fetchLimit = 1
                                    fetchRequest.returnsObjectsAsFaults = false
                                    fetchRequest.relationshipKeyPathsForPrefetching = ["userDetails"]

                                    let user = try context.fetch(fetchRequest).first

                                    let previousUserDetail = user?.sortedUserDetails?.last

                                    // Don't update user data if user has account. (Might overwrite followings/followers list)
                                    guard twitterUser.id == accountUserID || user?.accounts?.isEmpty != false else {
                                        return (previousUserDetail?.objectID, nil)
                                    }

                                    let userDetail = try UserDetail.createOrUpdate(
                                        twitterUser: twitterUser,
                                        profileHeaderImageURL: profileHeaderImageURL,
                                        followingUserIDs: followingUserIDs,
                                        followerUserIDs: followerIDs,
                                        blockingUserIDs: myBlockingUserIDs,
                                        mutingUserIDs: myMutingUserIDs,
                                        userUpdateStartDate: chunkedUsers.0,
                                        userDetailCreationDate: twitterUserFetchDate,
                                        context: context
                                    )

                                    return (previousUserDetail?.objectID, userDetail.objectID)
                                }

                                try Task.checkCancellation()
                                try await _ = _updatingUsers

                                if let profileImageOriginalURL = twitterUser.profileImageOriginalURL {
                                    Task.detached(priority: .utility) {
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
                                }

                                if let profileHeaderImageURL = profileHeaderImageURL {
                                    Task.detached(priority: .utility) {
                                        await withExtendedBackgroundExecution {
                                            do {
                                                try Task.checkCancellation()

                                                try await DataAsset.dataAsset(for: profileHeaderImageURL, session: self, context: dataAssetContext) { _ in
                                                    if dataAssetContext.hasChanges {
                                                        try dataAssetContext.save()
                                                    }
                                                }
                                            } catch {
                                                Logger(subsystem: Bundle.tweetNestKit.bundleIdentifier!, category: "fetch-profile-header-image")
                                                    .error("Error occurred while downloading image: \(String(reflecting: error), privacy: .public)")
                                            }
                                        }
                                    }
                                }

                                return (twitterUser.id, .success(userDetailObjectIDs))
                            }
                        }

                        for twitterError in chunkedUsers.1.errors {
                            try Task.checkCancellation()

                            Logger(subsystem: Bundle.tweetNestKit.bundleIdentifier!, category: "fetch-user")
                                .error("Error occurred while fetch user: \(twitterError as NSError, privacy: .public)")

                            taskGroup.addTask {
                                guard let value = twitterError.value else {
                                    throw twitterError
                                }

                                return (value, .failure(twitterError))
                            }
                        }
                    }

                    let userDetailObjectIDs: [Twitter.User.ID: Result<(oldUserDetailObjectID: NSManagedObjectID?, newUserDetailObjectID: NSManagedObjectID?), TwitterServerError>] = try await taskGroup.reduce(into: [:]) {
                        try Task.checkCancellation()

                        $0[$1.0] = $1.1
                    }

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
