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
            try await withThrowingTaskGroup(of: (Date, (users: [Twitter.User], errors: [TwitterServerError])).self) { chunkedUsersTaskGroup in
                let context = _context ?? {
                    let context = self.persistentContainer.newBackgroundContext()
                    context.undoManager = nil

                    return context
                }()

                async let userIDs: [Twitter.User.ID] = context.perform { [userIDs = Set(userIDs)] in
                    let userFetchRequest: NSFetchRequest<User> = User.fetchRequest()
                    userFetchRequest.predicate = NSPredicate(format: "id IN %@", userIDs)
                    userFetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                    userFetchRequest.returnsObjectsAsFaults = false

                    let users = Dictionary(
                        try context.fetch(userFetchRequest).map { ($0.id, $0) },
                        uniquingKeysWith: {
                            if ($0.creationDate ?? .distantPast) < ($1.creationDate ?? .distantPast) {
                                return $1
                            } else {
                                return $0
                            }
                        }
                    )

                    let refinedUserIDs: [Twitter.User.ID] = userIDs.compactMap {
                        let user = users[$0]
                        let lastUpdateStartDate = user?.lastUpdateStartDate ?? .distantPast

                        guard lastUpdateStartDate.addingTimeInterval(60) < Date() else {
                            return nil
                        }

                        // Don't update user data if user has account. (Might overwrite followings/followers list)
                        guard $0 == accountUserID || user?.accounts?.isEmpty != false else {
                            return nil
                        }

                        user?.lastUpdateStartDate = Date()

                        return $0
                    }

                    context.perform {
                        if context.hasChanges {
                            do {
                                try context.save()
                            } catch {
                                Logger(label: Bundle.tweetNestKit.bundleIdentifier!, category: String(reflecting: Self.self))
                                    .error("\(error as NSError, privacy: .public)")
                            }
                        }
                    }

                    return refinedUserIDs
                }

                async let _preferences = context.perform(schedule: .enqueued) {
                    self.preferences(for: context).preferences
                }

                async let _accountPreferences = context.perform(schedule: .enqueued) { () -> Account.Preferences in
                    guard let account = try? context.existingObject(with: accountObjectID) as? Account else {
                        throw SessionError.unknown
                    }

                    return account.preferences
                }

                let twitterSession = try await self.twitterSession(for: accountObjectID)

                for chunkedUserIDs in try await userIDs.chunks(ofCount: 100) {
                    chunkedUsersTaskGroup.addTask {
                        try await (Date(), Twitter.User.users(ids: Array(chunkedUserIDs), session: twitterSession))
                    }
                }

                let preferences = await _preferences
                let accountPreferences = try await _accountPreferences

                return try await withThrowingTaskGroup(of: (Twitter.User.ID, Result<(oldUserDetailObjectID: NSManagedObjectID?, newUserDetailObjectID: NSManagedObjectID?), TwitterServerError>).self) { taskGroup in
                    for try await chunkedUsers in chunkedUsersTaskGroup {
                        for twitterUser in chunkedUsers.1.users {
                            try Task.checkCancellation()

                            taskGroup.addTask {
                                async let _profileBanner = preferences.fetchProfileHeaderImages == true ? twitterUser.profileBanner(session: twitterSession) : nil

                                async let _followingUserIDs = twitterUser.id == accountUserID ? Twitter.User.followingUserIDs(forUserID: twitterUser.id, session: twitterSession).userIDs : nil
                                async let _followerIDs = twitterUser.id == accountUserID ? Twitter.User.followerIDs(forUserID: twitterUser.id, session: twitterSession).userIDs : nil
                                async let _myBlockingUserIDs = twitterUser.id == accountUserID && accountPreferences.fetchBlockingUsers ? Twitter.User.myBlockingUserIDs(session: twitterSession).userIDs : nil
                                async let _myMutingUserIDs = twitterUser.id == accountUserID && accountPreferences.fetchMutingUsers ? Twitter.User.myMutingUserIDs(session: twitterSession).userIDs : nil

                                let followingUserIDs = try await _followingUserIDs
                                let followerIDs = try await _followerIDs
                                let myBlockingUserIDs = try await _myBlockingUserIDs
                                let myMutingUserIDs = try await _myMutingUserIDs
                                let twitterUserFetchDate = Date()

                                try Task.checkCancellation()
                                
                                let userIDs = OrderedSet<Twitter.User.ID>([followingUserIDs, followerIDs, myBlockingUserIDs, myMutingUserIDs].flatMap { $0 ?? [] })
                                async let _updatingUsers = self.updateUsers(ids: userIDs, accountObjectID: accountObjectID, context: context)

                                try Task.checkCancellation()

                                let profileHeaderImageURL = try await _profileBanner?.sizes.max(by: { $0.value.width < $1.value.width })?.value.url

                                let userDetailObjectIDs: (NSManagedObjectID?, NSManagedObjectID?) = try await context.perform(schedule: .enqueued) {
                                    let fetchRequest = UserDetail.fetchRequest()
                                    fetchRequest.predicate = NSPredicate(format: "user.id == %@", twitterUser.id)
                                    fetchRequest.sortDescriptors = [
                                        NSSortDescriptor(key: "user.modificationDate", ascending: false),
                                        NSSortDescriptor(key: "user.creationDate", ascending: false),
                                        NSSortDescriptor(key: "creationDate", ascending: false),
                                    ]
                                    fetchRequest.fetchLimit = 1
                                    fetchRequest.returnsObjectsAsFaults = false
                                    fetchRequest.relationshipKeyPathsForPrefetching = ["user", "user.accounts"]

                                    let previousUserDetail = try context.fetch(fetchRequest).first

                                    // Don't update user data if user has account. (Might overwrite followings/followers list)
                                    guard twitterUser.id == accountUserID || previousUserDetail?.user?.accounts?.isEmpty != false else {
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
                                        previousUserDetail: previousUserDetail,
                                        context: context
                                    )

                                    return (previousUserDetail?.objectID, userDetail.objectID)
                                }

                                if let profileImageOriginalURL = twitterUser.profileImageOriginalURL {
                                    self.dataAssetsURLSessionManager.download(profileImageOriginalURL)
                                }

                                if let profileHeaderImageURL = profileHeaderImageURL {
                                    self.dataAssetsURLSessionManager.download(profileHeaderImageURL)
                                }

                                try Task.checkCancellation()
                                try await _ = _updatingUsers

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

                    try await context.perform(schedule: .enqueued) {
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
