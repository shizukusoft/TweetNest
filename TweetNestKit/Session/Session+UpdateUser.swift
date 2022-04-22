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
    public func updateUsers<S>(
        ids userIDs: S,
        accountObjectID: NSManagedObjectID,
        context: NSManagedObjectContext? = nil
    ) async throws -> [Twitter.User.ID: Result<(oldUserDetailObjectID: NSManagedObjectID?, newUserDetailObjectID: NSManagedObjectID?), TwitterServerError>] where S: Sequence, S.Element == Twitter.User.ID {
        try await updateUsers(ids: userIDs, accountObjectID: accountObjectID, accountUserID: nil, context: context)
    }

    @discardableResult
    func updateUsers<S>(
        ids userIDs: S,
        accountObjectID: NSManagedObjectID,
        accountUserID: String? = nil,
        context _context: NSManagedObjectContext? = nil
    ) async throws -> [Twitter.User.ID: Result<(oldUserDetailObjectID: NSManagedObjectID?, newUserDetailObjectID: NSManagedObjectID?), TwitterServerError>] where S: Sequence, S.Element == Twitter.User.ID {
        try await withThrowingTaskGroup(of: (Date, (users: [Twitter.User], errors: [TwitterServerError])).self) { chunkedUsersTaskGroup in
            let context = _context ?? {
                let context = self.persistentContainer.newBackgroundContext()
                context.undoManager = nil

                return context
            }()

            async let _refinedUsersByID: [Twitter.User.ID: User?] = context.perform { [userIDs = Set(userIDs)] in
                let userFetchRequest: NSFetchRequest<User> = User.fetchRequest()
                userFetchRequest.predicate = NSPredicate(format: "id IN %@", userIDs)
                userFetchRequest.sortDescriptors = [
                    NSSortDescriptor(keyPath: \User.modificationDate, ascending: false),
                    NSSortDescriptor(keyPath: \User.creationDate, ascending: false)
                ]
                userFetchRequest.returnsObjectsAsFaults = false

                let users = try context.fetch(userFetchRequest)
                let usersByID = Dictionary(uniqueKeysWithValues: users.lazy.uniqued(on: \.id).map { ($0.id, $0) })

                let refinedUsersByID: [Twitter.User.ID: User?] = Dictionary(
                    uniqueKeysWithValues: userIDs
                        .lazy
                        .compactMap {
                            let user = usersByID[$0]
                            let lastUpdateStartDate = user?.lastUpdateStartDate ?? .distantPast

                            guard lastUpdateStartDate.addingTimeInterval(60) < Date() else {
                                return nil
                            }

                            user?.lastUpdateStartDate = Date()

                            return ($0, user)
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

                return refinedUsersByID
            }

            async let _preferences = ManagedPreferences.Preferences(for: context)

            async let _accountPreferences = context.perform(schedule: .enqueued) { () -> Account.Preferences in
                guard let account = try? context.existingObject(with: accountObjectID) as? Account else {
                    throw SessionError.unknown
                }

                return account.preferences
            }

            try Task.checkCancellation()

            let twitterSession = try await self.twitterSession(for: accountObjectID)
            let refinedUsersByID = try await _refinedUsersByID

            try Task.checkCancellation()

            for chunkecUserIDs in refinedUsersByID.keys.chunks(ofCount: 100) {
                chunkedUsersTaskGroup.addTask {
                    try await withExtendedBackgroundExecution {
                        try await (Date(), Twitter.User.users(ids: Array(chunkecUserIDs), session: twitterSession))
                    }
                }
            }

            try Task.checkCancellation()

            let preferences = await _preferences
            let accountPreferences = try await _accountPreferences

            return try await withThrowingTaskGroup(of: (Twitter.User.ID, Result<(oldUserDetailObjectID: NSManagedObjectID?, newUserDetailObjectID: NSManagedObjectID?), TwitterServerError>).self) { taskGroup in
                for try await chunkedUsers in chunkedUsersTaskGroup {
                    for twitterUser in chunkedUsers.1.users {
                        taskGroup.addTask {
                            async let _followingUserIDs = twitterUser.id == accountUserID ? withExtendedBackgroundExecution { try await Twitter.User.followingUserIDs(forUserID: twitterUser.id, session: twitterSession).userIDs } : nil
                            async let _followerIDs = twitterUser.id == accountUserID ? withExtendedBackgroundExecution { try await Twitter.User.followerIDs(forUserID: twitterUser.id, session: twitterSession).userIDs } : nil
                            async let _myBlockingUserIDs = twitterUser.id == accountUserID && accountPreferences.fetchBlockingUsers ? withExtendedBackgroundExecution { try await Twitter.User.myBlockingUserIDs(session: twitterSession).userIDs } : nil
                            async let _myMutingUserIDs = twitterUser.id == accountUserID && accountPreferences.fetchMutingUsers ? withExtendedBackgroundExecution { try await Twitter.User.myMutingUserIDs(session: twitterSession).userIDs } : nil
                            async let _profileBanner = preferences.fetchProfileHeaderImages == true ? withExtendedBackgroundExecution { try await twitterUser.profileBanner(session: twitterSession) } : nil

                            try Task.checkCancellation()
                            
                            let followingUserIDs = try await _followingUserIDs
                            let followerIDs = try await _followerIDs
                            let myBlockingUserIDs = try await _myBlockingUserIDs
                            let myMutingUserIDs = try await _myMutingUserIDs
                            let profileHeaderImageURL = try await _profileBanner?.sizes.max(by: { $0.value.width < $1.value.width })?.value.url
                            let twitterUserFetchDate = Date()

                            async let _updatingUsers = self.updateUsers(
                                ids: Set<Twitter.User.ID>([followingUserIDs, followerIDs, myBlockingUserIDs, myMutingUserIDs].compacted().joined()),
                                accountObjectID: accountObjectID,
                                context: context
                            )

                            try Task.checkCancellation()

                            let userDetailObjectIDs: (NSManagedObjectID?, NSManagedObjectID?) = try await context.perform(schedule: .enqueued) {
                                let user = refinedUsersByID[twitterUser.id] as? User
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
                        taskGroup.addTask {
                            Logger(subsystem: Bundle.tweetNestKit.bundleIdentifier!, category: "fetch-user")
                                .error("Error occurred while fetch user: \(twitterError as NSError, privacy: .public)")

                            guard let value = twitterError.value else {
                                throw twitterError
                            }

                            return (value, .failure(twitterError))
                        }
                    }
                }

                let userDetailObjectIDs: [Twitter.User.ID: Result<(oldUserDetailObjectID: NSManagedObjectID?, newUserDetailObjectID: NSManagedObjectID?), TwitterServerError>] = try await taskGroup.reduce(into: [:]) {
                    $0[$1.0] = $1.1
                }

                try await context.perform(schedule: .enqueued) {
                    if context.hasChanges {
                        try withExtendedBackgroundExecution {
                            try context.save()
                        }
                    }
                }

                return userDetailObjectIDs
            }
        }
    }
}
