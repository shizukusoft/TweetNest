//
//  Session+UpdateAccount.swift
//  Session+UpdateAccount
//
//  Created by Jaehong Kang on 2021/08/16.
//

import Foundation
import CoreData
import UserNotifications
import UnifiedLogging
import Twitter
import OrderedCollections

extension Session {
    @discardableResult
    public nonisolated func updateAllAccounts() async throws -> [(NSManagedObjectID, Result<Bool, Swift.Error>)] {
        let context = persistentContainer.newBackgroundContext()
        context.undoManager = nil

        let accountObjectIDs: [NSManagedObjectID] = try await context.perform(schedule: .enqueued) {
            let fetchRequest = NSFetchRequest<NSManagedObjectID>(entityName: Account.entity().name!)
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(keyPath: \Account.preferringSortOrder, ascending: true),
                NSSortDescriptor(keyPath: \Account.creationDate, ascending: false)
            ]
            fetchRequest.resultType = .managedObjectIDResultType

            return try context.fetch(fetchRequest)
        }

        return await withTaskGroup(of: (NSManagedObjectID, Result<Bool, Swift.Error>).self) { taskGroup in
            accountObjectIDs.forEach { accountObjectID in
                taskGroup.addTask {
                    do {
                        let updateResults = try await self.updateAccount(accountObjectID)
                        return (accountObjectID, .success(updateResults.previousUserDetailObjectID != updateResults.latestUserDetailObjectID))
                    } catch {
                        return (accountObjectID, .failure(error))
                    }
                }
            }

            return await taskGroup.reduce(into: [], { $0.append($1) })
        }
    }
    
    @discardableResult
    public nonisolated func updateAccount(
        _ accountObjectID: NSManagedObjectID,
        context _context: NSManagedObjectContext? = nil
    ) async throws -> (previousUserDetailObjectID: NSManagedObjectID?, latestUserDetailObjectID: NSManagedObjectID) {
        try await withExtendedBackgroundExecution {
            let context = _context ?? self.persistentContainer.newBackgroundContext()
            context.undoManager = _context?.undoManager

            let updateStartDate = Date()
            let (accountID, accountPreferences) = try await context.perform { () -> (Int64, Account.Preferences) in
                guard let account = try? context.existingObject(with: accountObjectID) as? Account else {
                    throw SessionError.unknown
                }

                account.user?.lastUpdateStartDate = updateStartDate
                account.user?.lastUpdateEndDate = nil

                try context.save()

                return (account.id, account.preferences)
            }

            let twitterSession = try await self.twitterSession(for: accountObjectID)

            let userID = String(accountID)

            async let _twitterUser = Twitter.User(id: userID, session: twitterSession)
            async let _followingUserIDs = Twitter.User.followingUserIDs(forUserID: userID, session: twitterSession)
            async let _followerIDs = Twitter.User.followerIDs(forUserID: userID, session: twitterSession)
            async let _myBlockingUserIDs = accountPreferences.fetchBlockingUsers ? Twitter.User.myBlockingUserIDs(session: twitterSession) : nil

            let twitterUser = try await _twitterUser
            async let _profileImageDataAsset = UserDefaults.tweetNestKit(Session.downloadUserProfileImagesUserDefaultsKey, type: Bool.self) == true ? DataAsset.dataAsset(for: twitterUser.profileImageOriginalURL, session: self, context: context) : nil

            let followingUserIDs = try await _followingUserIDs
            let followerIDs = try await _followerIDs
            let myBlockingUserIDs = try await _myBlockingUserIDs
            let twitterUserFetchDate = Date()
            
            let userIDs = OrderedSet<Twitter.User.ID>(followingUserIDs + followerIDs + (myBlockingUserIDs ?? []))
            async let _updatingUsers: Void = self.updateUsers(ids: userIDs, twitterSession: twitterSession, context: context)

            async let userDetailObjectIDs: (NSManagedObjectID?, NSManagedObjectID) = context.perform(schedule: .enqueued) {
                try Task.checkCancellation()
                
                let account = context.object(with: accountObjectID) as! Account

                let fetchRequest = User.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %@", userID)
                fetchRequest.relationshipKeyPathsForPrefetching = ["userDetails"]

                let user = try context.fetch(fetchRequest).last
                let previousUserDetail = user?.sortedUserDetails?.last

                let userDetail = try UserDetail.createOrUpdate(
                    twitterUser: twitterUser,
                    followingUserIDs: followingUserIDs,
                    followerUserIDs: followerIDs,
                    blockingUserIDs: myBlockingUserIDs,
                    userUpdateStartDate: updateStartDate,
                    userDetailCreationDate: twitterUserFetchDate,
                    context: context
                )

                userDetail.user?.account = account

                try context.save()

                return (previousUserDetail?.objectID, userDetail.objectID)
            }
            
            let profileImageDataAsset = try await _profileImageDataAsset
            if let profileImageDataAsset = profileImageDataAsset, profileImageDataAsset.hasChanges {
                try await context.perform {
                    try context.save()
                }
            }

            try await _updatingUsers

            return try await userDetailObjectIDs
        }
    }
}
