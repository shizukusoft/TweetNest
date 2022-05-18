//
//  Session+RemoteChanges.swift
//  Session+RemoteChanges
//
//  Created by Jaehong Kang on 2021/09/01.
//

import Foundation
import Twitter
import CoreData
import CloudKit
import UserNotifications
import Algorithms
import OrderedCollections
import BackgroundTask
import UnifiedLogging

extension Session {
    private var logger: Logger {
        Logger(subsystem: Bundle.tweetNestKit.bundleIdentifier!, category: "remote-changes")
    }

    private static var lastPersistentHistoryToken: NSPersistentHistoryToken? {
        get throws {
            try TweetNestKitUserDefaults.standard.lastPersistentHistoryTokenData.flatMap {
                try NSKeyedUnarchiver.unarchivedObject(
                    ofClass: NSPersistentHistoryToken.self,
                    from: $0
                )
            }
        }
    }

    private static func setLastPersistentHistoryToken(_ newValue: NSPersistentHistoryToken?) throws {
        TweetNestKitUserDefaults.standard.lastPersistentHistoryTokenData = try newValue.flatMap {
            try NSKeyedArchiver.archivedData(
                withRootObject: $0,
                requiringSecureCoding: true
            )
        }
    }

    func handlePersistentStoreRemoteChanges(_ currentPersistentHistoryToken: NSPersistentHistoryToken?) {
        do {
            try withExtendedBackgroundExecution {
                guard let lastPersistentHistoryToken = try Self.lastPersistentHistoryToken else {
                    try Self.setLastPersistentHistoryToken(currentPersistentHistoryToken)

                    return
                }

                let context = self.persistentContainer.newBackgroundContext()
                let persistentHistoryResult = try context.performAndWait {
                    try context.execute(
                        NSPersistentHistoryChangeRequest.fetchHistory(
                            after: lastPersistentHistoryToken
                        )
                    )
                } as? NSPersistentHistoryResult

                guard
                    let persistentHistoryTransactions = persistentHistoryResult?.result as? [NSPersistentHistoryTransaction],
                    let newLastPersistentHistoryToken = persistentHistoryTransactions.last?.token
                else {
                    try Self.setLastPersistentHistoryToken(currentPersistentHistoryToken)

                    return
                }

                Task.detached {
                    await withTaskGroup(of: Void.self) { taskGroup in
                        taskGroup.addTask {
                            await self.updateNotifications(transactions: persistentHistoryTransactions)
                        }

                        taskGroup.addTask {
                            await self.updateAccountCredential(transactions: persistentHistoryTransactions)
                        }

                        taskGroup.addTask(priority: .utility) {
                            await self.cleansingAccount(transactions: persistentHistoryTransactions)
                        }

                        taskGroup.addTask(priority: .utility) {
                            await self.cleansingUser(transactions: persistentHistoryTransactions)
                        }

                        taskGroup.addTask(priority: .utility) {
                            await self.cleansingUserDataAssets(transactions: persistentHistoryTransactions)
                        }

                        await taskGroup.waitForAll()
                    }
                }

                try Self.setLastPersistentHistoryToken(newLastPersistentHistoryToken)
            }
        } catch {
            self.logger.error("Error occurred while handle persistent store remote changes: \(error as NSError, privacy: .public)")

            do {
                try Self.setLastPersistentHistoryToken(currentPersistentHistoryToken)
            } catch {
                try? Self.setLastPersistentHistoryToken(nil)
            }
        }
    }

    private func updateAccountCredential(transactions: [NSPersistentHistoryTransaction]) async {
        let changedAccountObjectIDs = transactions.lazy
            .compactMap(\.changes)
            .joined()
            .filter { $0.changedObjectID.entity == ManagedAccount.entity() }
            .filter { $0.changeType == .update }
            .map(\.changedObjectID)
            .uniqued()

        let context = self.persistentContainer.newBackgroundContext()
        context.undoManager = nil

        for changedAccountObjectID in changedAccountObjectIDs {
            let credential: Twitter.Session.Credential? = await context.perform {
                guard let account = context.object(with: changedAccountObjectID) as? ManagedAccount else {
                    return nil
                }

                return account.credential
            }

            guard let twitterSession = await self.sessionActor.twitterSessions[changedAccountObjectID.uriRepresentation()] else {
                return
            }

            await twitterSession.updateCredential(credential)
        }
    }
}

extension Session {
    private func cleansingAccount(transactions: [NSPersistentHistoryTransaction]) async {
        let changedAccountObjectIDs = transactions.lazy
            .compactMap(\.changes)
            .joined()
            .filter { $0.changedObjectID.entity == ManagedAccount.entity() }
            .filter { $0.changeType == .insert }
            .map(\.changedObjectID)
            .uniqued()

        let context = self.persistentContainer.newBackgroundContext()
        context.undoManager = nil

        for changedAccountObjectID in changedAccountObjectIDs {
            do {
                try await self.cleansingAccount(for: changedAccountObjectID, context: context)
            } catch {
                self.logger.error("Error occurred while cleansing account: \(error as NSError, privacy: .public)")
            }
        }
    }

    private func cleansingUser(transactions: [NSPersistentHistoryTransaction]) async {
        let changedUserObjectIDs = transactions.lazy
            .compactMap(\.changes)
            .joined()
            .filter { $0.changedObjectID.entity == ManagedUser.entity() }
            .filter { $0.changeType == .insert }
            .map(\.changedObjectID)
            .uniqued()

        let context = self.persistentContainer.newBackgroundContext()
        context.undoManager = nil

        for changedUserObjectID in changedUserObjectIDs {
            do {
                try await self.cleansingUser(for: changedUserObjectID, context: context)
            } catch {
                self.logger.error("Error occurred while cleansing user: \(error as NSError, privacy: .public)")
            }
        }
    }

    private func cleansingUserDataAssets(transactions: [NSPersistentHistoryTransaction]) async {
        let changedUserDataAssetObjectIDs = transactions.lazy
            .compactMap(\.changes)
            .joined()
            .filter { $0.changedObjectID.entity == ManagedUserDataAsset.entity() }
            .filter { $0.changeType == .insert }
            .map(\.changedObjectID)
            .uniqued()

        let context = self.persistentContainer.newBackgroundContext()
        context.undoManager = nil

        for changedUserDataAssetObjectID in changedUserDataAssetObjectIDs {
            do {
                try await self.cleansingUserDataAsset(for: changedUserDataAssetObjectID, context: context)
            } catch {
                self.logger.error("Error occurred while cleansing data asset: \(error as NSError, privacy: .public)")
            }
        }
    }
}

extension Session {
    private func notificationContent(for newUserDetail: ManagedUserDetail, preferences: ManagedPreferences.Preferences, context: NSManagedObjectContext) -> UNNotificationContent? {
        guard
            let userID = newUserDetail.userID,
            let newUserDetailCreationDate = newUserDetail.creationDate
        else {
            return nil
        }

        let oldUserDetailFetchRequest = ManagedUserDetail.fetchRequest()
        oldUserDetailFetchRequest.predicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: [
                NSPredicate(format: "userID == %@", userID),
                NSPredicate(format: "creationDate < %@", newUserDetailCreationDate as NSDate)
            ]
        )
        oldUserDetailFetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \ManagedUserDetail.creationDate, ascending: false)
        ]
        oldUserDetailFetchRequest.fetchLimit = 1
        oldUserDetailFetchRequest.returnsObjectsAsFaults = false

        guard let oldUserDetail = try? context.fetch(oldUserDetailFetchRequest).first else {
            return nil
        }

        let notificationContent = UNMutableNotificationContent()
        if let name = newUserDetail.name {
            notificationContent.title = name
        }
        notificationContent.subtitle = newUserDetail.displayUsername ?? userID.displayUserID
        notificationContent.threadIdentifier = userID
        notificationContent.categoryIdentifier = "NewAccountData"
        notificationContent.sound = .default
        notificationContent.interruptionLevel = .timeSensitive

        var changes: [String] = []

        if preferences.notifyProfileChanges {
            if oldUserDetail.isProfileEqual(to: newUserDetail) == false {
                changes.append(String(localized: "New Profile", bundle: .tweetNestKit, comment: "background-refresh notification body."))
            }
        }

        if preferences.notifyFollowingChanges, let followingUserIDsChanges = newUserDetail.userIDsChange(from: oldUserDetail, for: \.followingUserIDs) {
            if followingUserIDsChanges.addedUserIDs.count > 0 {
                changes.append(String(localized: "\(followingUserIDsChanges.addedUserIDs.count, specifier: "%ld") New Following(s)", bundle: .tweetNestKit, comment: "background-refresh notification body."))
            }
            if followingUserIDsChanges.removedUserIDs.count > 0 {
                changes.append(String(localized: "\(followingUserIDsChanges.removedUserIDs.count, specifier: "%ld") New Unfollowing(s)", bundle: .tweetNestKit, comment: "background-refresh notification body."))
            }
        }

        if preferences.notifyFollowerChanges, let followerUserIDsChanges = newUserDetail.userIDsChange(from: oldUserDetail, for: \.followerUserIDs) {
            if followerUserIDsChanges.addedUserIDs.count > 0 {
                changes.append(String(localized: "\(followerUserIDsChanges.addedUserIDs.count, specifier: "%ld") New Follower(s)", bundle: .tweetNestKit, comment: "background-refresh notification body."))
            }
            if followerUserIDsChanges.removedUserIDs.count > 0 {
                changes.append(String(localized: "\(followerUserIDsChanges.removedUserIDs.count, specifier: "%ld") New Unfollower(s)", bundle: .tweetNestKit, comment: "background-refresh notification body."))
            }
        }

        if preferences.notifyBlockingChanges, let blockingUserIDsChanges = newUserDetail.userIDsChange(from: oldUserDetail, for: \.blockingUserIDs) {
            if blockingUserIDsChanges.addedUserIDs.count > 0 {
                changes.append(String(localized: "\(blockingUserIDsChanges.addedUserIDs.count, specifier: "%ld") New Block(s)", bundle: .tweetNestKit, comment: "background-refresh notification body."))
            }
            if blockingUserIDsChanges.removedUserIDs.count > 0 {
                changes.append(String(localized: "\(blockingUserIDsChanges.removedUserIDs.count, specifier: "%ld") New Unblock(s)", bundle: .tweetNestKit, comment: "background-refresh notification body."))
            }
        }

        if preferences.notifyMutingChanges, let mutingUserIDsChanges = newUserDetail.userIDsChange(from: oldUserDetail, for: \.mutingUserIDs) {
            if mutingUserIDsChanges.addedUserIDs.count > 0 {
                changes.append(String(localized: "\(mutingUserIDsChanges.addedUserIDs.count, specifier: "%ld") New Mute(s)", bundle: .tweetNestKit, comment: "background-refresh notification body."))
            }
            if mutingUserIDsChanges.removedUserIDs.count > 0 {
                changes.append(String(localized: "\(mutingUserIDsChanges.removedUserIDs.count, specifier: "%ld") New Unmute(s)", bundle: .tweetNestKit, comment: "background-refresh notification body."))
            }
        }

        guard changes.isEmpty == false else {
            return nil
        }

        notificationContent.body = changes.formatted(.list(type: .and, width: .narrow))

        return notificationContent
    }

    private func updateNotifications(transactions: [NSPersistentHistoryTransaction]) async {
        do {
            try await withExtendedBackgroundExecution {
                let changes = OrderedDictionary<NSManagedObjectID, NSPersistentHistoryChange>(
                    transactions.lazy
                        .compactMap(\.changes)
                        .joined()
                        .filter { $0.changedObjectID.entity == ManagedUserDetail.entity() }
                        .map { ($0.changedObjectID, $0) },
                    uniquingKeysWith: { (_, last) in last }
                )

                guard changes.isEmpty == false else {
                    return
                }

                let updatedObjectIDs: [NSManagedObjectID] = changes.lazy
                    .filter { $0.value.changeType == .insert || $0.value.changeType == .update }
                    .map { $0.key }

                let context = self.persistentContainer.newBackgroundContext()

                let (_userDetails, preferences): ([ManagedUserDetail], ManagedPreferences.Preferences) = try await context.perform {
                    let preferences = ManagedPreferences.managedPreferences(for: context).preferences

                    let accountUserIDsfetchRequest = NSFetchRequest<NSDictionary>()
                    accountUserIDsfetchRequest.entity = ManagedAccount.entity()
                    accountUserIDsfetchRequest.resultType = .dictionaryResultType
                    accountUserIDsfetchRequest.propertiesToFetch = ["userID"]
                    accountUserIDsfetchRequest.returnsDistinctResults = true

                    let results = try context.fetch(accountUserIDsfetchRequest)
                    let accountUserIDs = results.compactMap {
                        $0["userID"] as? Twitter.User.ID
                    }

                    guard accountUserIDs.isEmpty == false else {
                        return ([], preferences)
                    }

                    let userDetailsFetchRequest = ManagedUserDetail.fetchRequest()
                    userDetailsFetchRequest.predicate = NSCompoundPredicate(
                        andPredicateWithSubpredicates: [
                            NSPredicate(format: "SELF IN %@", updatedObjectIDs),
                            NSPredicate(format: "creationDate >= %@", Date(timeIntervalSinceNow: -(60 * 60)) as NSDate),
                            NSPredicate(format: "userID IN %@", accountUserIDs)
                        ]
                    )
                    userDetailsFetchRequest.returnsObjectsAsFaults = false

                    let userDetails = try context.fetch(userDetailsFetchRequest)

                    return (userDetails, preferences)
                }

                try await withThrowingTaskGroup(of: (NSManagedObjectID, CKRecord.ID?, UNNotificationContent?).self) { notificationContentsTaskGroup in
                    for _userDetail in _userDetails {
                        notificationContentsTaskGroup.addTask {
                            (
                                _userDetail.objectID,
                                self.persistentContainer.recordID(for: _userDetail.objectID),
                                await context.perform {
                                    self.notificationContent(for: _userDetail, preferences: preferences, context: context)
                                }
                            )
                        }
                    }

                    var hasChangesObjectIDs = OrderedSet<NSManagedObjectID>()

                    for try await (managedObjectID, cloudKitRecordID, notificationContent) in notificationContentsTaskGroup {
                        guard let notificationContent = notificationContent else { continue }

                        hasChangesObjectIDs.append(managedObjectID)

                        try await UNUserNotificationCenter.current().add(
                            UNNotificationRequest(
                                identifier: cloudKitRecordID?.recordName ?? managedObjectID.uriRepresentation().absoluteString,
                                content: notificationContent,
                                trigger: nil
                            )
                        )
                    }

                    let needsToBeRemovedObjectIDs = changes.keys.subtracting(hasChangesObjectIDs)
                    Task.detached(priority: .utility) {
                        await Task.yield()

                        do {
                            try withExtendedBackgroundExecution(expirationHandler: nil) {
                                let cloudKitRecordIDs = self.persistentContainer.recordIDs(for: needsToBeRemovedObjectIDs.elements)

                                let userNotificationIdentifiers = needsToBeRemovedObjectIDs.flatMap {
                                    [cloudKitRecordIDs[$0]?.recordName, $0.uriRepresentation().absoluteString].compacted()
                                }

                                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: userNotificationIdentifiers)
                                UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: userNotificationIdentifiers)
                            }
                        } catch {
                            self.logger.error("Error occurred while update notifications: \(error as NSError, privacy: .public)")
                        }
                    }
                }
            }
        } catch {
            self.logger.error("Error occurred while update notifications: \(error as NSError, privacy: .public)")
        }
    }
}
