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
    public nonisolated func updateAllAccounts(requestUserNotificationForChanges: Bool = true) async throws -> [(NSManagedObjectID, Result<Bool, Swift.Error>)] {
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
                        let updateResults = try await self.updateAccount(accountObjectID, requestUserNotificationForChanges: requestUserNotificationForChanges)
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
        context _context: NSManagedObjectContext? = nil,
        requestUserNotificationForChanges: Bool = true
    ) async throws -> (previousUserDetailObjectID: NSManagedObjectID?, latestUserDetailObjectID: NSManagedObjectID) {
        try await withExtendedBackgroundExecution {
            let context = _context ?? persistentContainer.newBackgroundContext()
            context.undoManager = _context?.undoManager

            let updateStartDate = Date()
            let (accountID, accountPreferences) = try await context.perform { () -> (Int64, Account.Preferences) in
                guard let account = context.object(with: accountObjectID) as? Account else {
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
            async let _profileImageDataAsset = DataAsset.dataAsset(for: twitterUser.profileImageOriginalURL, session: self, context: context)

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
                
                if requestUserNotificationForChanges {
                    self.requestUserNotificationForChanges(account: account, oldUserDetail: previousUserDetail, newUserDetail: userDetail)
                }

                return (previousUserDetail?.objectID, userDetail.objectID)
            }
            
            let profileImageDataAsset = try await _profileImageDataAsset
            if profileImageDataAsset.hasChanges {
                try await context.perform {
                    try context.save()
                }
            }

            try await _updatingUsers

            return try await userDetailObjectIDs
        }
    }
    
    private nonisolated func requestUserNotificationForChanges(account: Account, oldUserDetail: UserDetail?, newUserDetail: UserDetail) {
        guard oldUserDetail?.objectID != newUserDetail.objectID else { return }
        
        let followingUserChanges = newUserDetail.followingUserChanges(from: oldUserDetail)
        let followerUserChanges = newUserDetail.followerUserChanges(from: oldUserDetail)
        
        let notificationContentTitle: String
        if let name = newUserDetail.name, let displayUsername = newUserDetail.displayUsername, name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
            notificationContentTitle = "\(name) (\(displayUsername))"
        } else if let displayUsername = newUserDetail.displayUsername {
            notificationContentTitle = displayUsername
        } else {
            notificationContentTitle = "#\(account.id.twnk_formatted())"
        }

        let notificationContent = UNMutableNotificationContent()
        notificationContent.threadIdentifier = account.objectID.uriRepresentation().absoluteString
        notificationContent.title = notificationContentTitle
        
        var changes: [String] = []
        if followingUserChanges.followingUsersCount > 0 {
            changes.append(String(localized: "\(followingUserChanges.followingUsersCount, specifier: "%ld") new following(s)", bundle: .module, comment: "background-refresh notification body."))
        }
        if followingUserChanges.unfollowingUsersCount > 0 {
            changes.append(String(localized: "\(followingUserChanges.unfollowingUsersCount, specifier: "%ld") new unfollowing(s)", bundle: .module, comment: "background-refresh notification body."))
        }
        if followerUserChanges.followerUsersCount > 0 {
            changes.append(String(localized: "\(followerUserChanges.followerUsersCount, specifier: "%ld") new follower(s)", bundle: .module, comment: "background-refresh notification body."))
        }
        if followerUserChanges.unfollowerUsersCount > 0 {
            changes.append(String(localized: "\(followerUserChanges.unfollowerUsersCount, specifier: "%ld") new unfollower(s)", bundle: .module, comment: "background-refresh notification body."))
        }
        
        if changes.isEmpty == false {
            notificationContent.subtitle = String(localized: "New Data Available", bundle: .module, comment: "background-refresh notification.")
            notificationContent.body = changes.formatted(.list(type: .and, width: .narrow))
        } else {
            notificationContent.body = String(localized: "New Data Available", bundle: .module, comment: "background-refresh notification.")
        }

        let notificationRequest = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: nil)

        Task {
            do {
                try await UNUserNotificationCenter.current().add(notificationRequest)
            } catch {
                Logger(subsystem: Bundle.module.bundleIdentifier!, category: "update-account")
                    .error("Error occurred while request notification: \(String(reflecting: error), privacy: .public)")
            }
        }
    }
}
