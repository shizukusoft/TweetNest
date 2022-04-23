//
//  Session+RemoteChanges.swift
//  Session+RemoteChanges
//
//  Created by Jaehong Kang on 2021/09/01.
//

import Foundation
import Twitter
import CoreData
import UserNotifications
import Algorithms
import OrderedCollections
import BackgroundTask
import UnifiedLogging

extension Session {
    private var logger: Logger {
        Logger(subsystem: Bundle.tweetNestKit.bundleIdentifier!, category: "remote-changes")
    }
    
    func handlePersistentStoreRemoteChanges() {
        persistentStoreRemoteChangeContext.perform { [persistentStoreRemoteChangeContext, logger] in
            do {
                let lastPersistentHistoryToken = try TweetNestKitUserDefaults.standard.lastPersistentHistoryTokenData.flatMap {
                    try NSKeyedUnarchiver.unarchivedObject(ofClass: NSPersistentHistoryToken.self, from: $0)
                }

                let fetchHistoryRequest = NSPersistentHistoryChangeRequest.fetchHistory(
                    after: lastPersistentHistoryToken
                )

                guard
                    let persistentHistoryResult = try persistentStoreRemoteChangeContext.execute(fetchHistoryRequest) as? NSPersistentHistoryResult,
                    let persistentHistoryTransactions = persistentHistoryResult.result as? [NSPersistentHistoryTransaction]
                else {
                    return
                }

                if let newLastPersistentHistoryToken = persistentHistoryTransactions.last?.token {
                    TweetNestKitUserDefaults.standard.lastPersistentHistoryTokenData = try NSKeyedArchiver.archivedData(withRootObject: newLastPersistentHistoryToken, requiringSecureCoding: true)
                }

                Task.detached {
                    await self.handleUserDetailChanges(transactions: persistentHistoryTransactions)
                }

                Task.detached(priority: .utility) {
                    await self.handleAccountChanges(transactions: persistentHistoryTransactions)
                }

                Task.detached(priority: .utility) {
                    await self.handleUserChanges(transactions: persistentHistoryTransactions)
                }

                Task.detached(priority: .utility) {
                    await self.handleDataAssetsChanges(transactions: persistentHistoryTransactions)
                }
            } catch {
                logger.error("Error occurred while handle persistent store remote changes: \(error as NSError, privacy: .public)")
            }
        }
    }

    private func handleAccountChanges(transactions: [NSPersistentHistoryTransaction]) async {
        let context = self.persistentContainer.newBackgroundContext()
        context.undoManager = nil

        let accountChangesByObjectID: OrderedDictionary<NSManagedObjectID, NSPersistentHistoryChange> = OrderedDictionary(
            Array(
                transactions
                    .lazy
                    .flatMap { $0.changes ?? [] }
                    .filter { $0.changedObjectID.entity == Account.entity() }
                    .map { ($0.changedObjectID, $0) }
            ),
            uniquingKeysWith: { $1 }
        )

        for (accountObjectID, change) in accountChangesByObjectID {
            func updateCredential() async {
                let credential: Twitter.Session.Credential? = await context.perform(schedule: .enqueued) {
                    guard let account = context.object(with: accountObjectID) as? Account else {
                        return nil
                    }

                    return account.credential
                }

                guard let twitterSession = await self.sessionActor.twitterSessions[accountObjectID.uriRepresentation()] else {
                    return
                }

                await twitterSession.updateCredential(credential)
            }

            func cleansingAccount() async {
                do {
                    try await self.cleansingAccount(for: accountObjectID, context: context)
                } catch {
                    self.logger.error("Error occurred while cleansing account: \(error as NSError, privacy: .public)")
                }
            }

            switch change.changeType {
            case .insert:
                await cleansingAccount()
            case .update:
                await updateCredential()
            case .delete:
                break
            @unknown default:
                break
            }
        }
    }

    private func handleUserChanges(transactions: [NSPersistentHistoryTransaction]) async {
        let context = self.persistentContainer.newBackgroundContext()
        context.undoManager = nil

        let userChangesByObjectID: OrderedDictionary<NSManagedObjectID, NSPersistentHistoryChange> = OrderedDictionary(
            Array(
                transactions
                    .lazy
                    .flatMap { $0.changes ?? [] }
                    .filter { $0.changedObjectID.entity == User.entity() }
                    .map { ($0.changedObjectID, $0) }
            ),
            uniquingKeysWith: { $1 }
        )

        for (userObjectID, change) in userChangesByObjectID {
            func cleansingUser() async {
                do {
                    try await self.cleansingUser(for: userObjectID, context: context)
                } catch {
                    self.logger.error("Error occurred while cleansing user: \(error as NSError, privacy: .public)")
                }
            }

            switch change.changeType {
            case .insert:
                await cleansingUser()
            case .update:
                break
            case .delete:
                break
            @unknown default:
                break
            }
        }
    }

    private func handleDataAssetsChanges(transactions: [NSPersistentHistoryTransaction]) async {
        let context = self.persistentContainer.newBackgroundContext()
        context.undoManager = nil

        let dataAssetChangesByObjectID: OrderedDictionary<NSManagedObjectID, NSPersistentHistoryChange> = OrderedDictionary(
            Array(
                transactions
                    .lazy
                    .flatMap { $0.changes ?? [] }
                    .filter { $0.changedObjectID.entity == DataAsset.entity() }
                    .map { ($0.changedObjectID, $0) }
            ),
            uniquingKeysWith: { $1 }
        )

        for (dataAssetObjectID, change) in dataAssetChangesByObjectID {
            func cleansingDataAsset() async {
                do {
                    try await self.cleansingDataAsset(for: dataAssetObjectID, context: context)
                } catch {
                    self.logger.error("Error occurred while cleansing data asset: \(error as NSError, privacy: .public)")
                }
            }

            switch change.changeType {
            case .insert:
                await cleansingDataAsset()
            case .update:
                break
            case .delete:
                break
            @unknown default:
                break
            }
        }
    }

    private func handleUserDetailChanges(transactions: [NSPersistentHistoryTransaction]) async {
        await withExtendedBackgroundExecution {
            let context = self.persistentContainer.newBackgroundContext()
            context.undoManager = nil

            let userDetailChangesByObjectID: OrderedDictionary<NSManagedObjectID, NSPersistentHistoryChange> = OrderedDictionary(
                Array(
                    transactions
                        .lazy
                        .flatMap { $0.changes ?? [] }
                        .filter { $0.changedObjectID.entity == UserDetail.entity() }
                        .map { ($0.changedObjectID, $0) }
                ),
                uniquingKeysWith: { $1 }
            )

            await withTaskGroup(of: Void.self) { addNotificationRequestTaskGroup in
                for (userDetailObjectID, change) in userDetailChangesByObjectID {
                    guard Task.isCancelled == false else { return }

                    switch change.changeType {
                    case .insert, .update:
                        let notificationRequest: UNNotificationRequest? = await context.perform(schedule: .enqueued) {
                            guard
                                let newUserDetail = context.object(with: userDetailObjectID) as? UserDetail,
                                Date(timeIntervalSinceNow: -(10 * 60)) <= (newUserDetail.creationDate ?? .distantPast),
                                let user = newUserDetail.user,
                                let sortedUserDetails = user.sortedUserDetails,
                                sortedUserDetails.count > 1,
                                let account = user.accounts?.max(by: { $0.creationDate ?? .distantPast < $1.creationDate ?? .distantPast })
                            else {
                                return nil
                            }

                            let oldUserDetailIndex = sortedUserDetails.lastIndex(of: newUserDetail).flatMap({ $0 - 1 })

                            guard let oldUserDetail = oldUserDetailIndex.flatMap({ sortedUserDetails.indices.contains($0) == true ? sortedUserDetails[$0] : nil }) else {
                                return nil
                            }

                            let preferences = ManagedPreferences.managedPreferences(for: context).preferences

                            let notificationContent = UNMutableNotificationContent()
                            notificationContent.title = newUserDetail.name ?? account.objectID.description
                            if let displayUsername = newUserDetail.displayUsername {
                                notificationContent.subtitle = displayUsername
                            } else if let userID = account.userID {
                                notificationContent.subtitle = userID.displayUserID
                            }
                            notificationContent.categoryIdentifier = "NewAccountData"
                            notificationContent.sound = .default
                            notificationContent.interruptionLevel = .timeSensitive
                            notificationContent.threadIdentifier = self.persistentContainer.recordID(for: account.objectID)?.recordName ?? account.objectID.uriRepresentation().absoluteString

                            var changes: [String] = []

                            if preferences.notifyProfileChanges {
                                if oldUserDetail.isProfileEqual(to: newUserDetail) == false {
                                    changes.append(String(localized: "New Profile", bundle: .tweetNestKit, comment: "background-refresh notification body."))
                                }
                            }

                            if preferences.notifyFollowingChanges, let followingUserIDsChanges = newUserDetail.userIDsChanges(from: oldUserDetail, for: \.followingUserIDs) {
                                if followingUserIDsChanges.addedUserIDsCount > 0 {
                                    changes.append(String(localized: "\(followingUserIDsChanges.addedUserIDsCount, specifier: "%ld") New Following(s)", bundle: .tweetNestKit, comment: "background-refresh notification body."))
                                }
                                if followingUserIDsChanges.removedUserIDsCount > 0 {
                                    changes.append(String(localized: "\(followingUserIDsChanges.removedUserIDsCount, specifier: "%ld") New Unfollowing(s)", bundle: .tweetNestKit, comment: "background-refresh notification body."))
                                }
                            }

                            if preferences.notifyFollowerChanges, let followerUserIDsChanges = newUserDetail.userIDsChanges(from: oldUserDetail, for: \.followerUserIDs) {
                                if followerUserIDsChanges.addedUserIDsCount > 0 {
                                    changes.append(String(localized: "\(followerUserIDsChanges.addedUserIDsCount, specifier: "%ld") New Follower(s)", bundle: .tweetNestKit, comment: "background-refresh notification body."))
                                }
                                if followerUserIDsChanges.removedUserIDsCount > 0 {
                                    changes.append(String(localized: "\(followerUserIDsChanges.removedUserIDsCount, specifier: "%ld") New Unfollower(s)", bundle: .tweetNestKit, comment: "background-refresh notification body."))
                                }
                            }

                            if preferences.notifyBlockingChanges, let blockingUserIDsChanges = newUserDetail.userIDsChanges(from: oldUserDetail, for: \.blockingUserIDs) {
                                if blockingUserIDsChanges.addedUserIDsCount > 0 {
                                    changes.append(String(localized: "\(blockingUserIDsChanges.addedUserIDsCount, specifier: "%ld") New Block(s)", bundle: .tweetNestKit, comment: "background-refresh notification body."))
                                }
                                if blockingUserIDsChanges.removedUserIDsCount > 0 {
                                    changes.append(String(localized: "\(blockingUserIDsChanges.removedUserIDsCount, specifier: "%ld") New Unblock(s)", bundle: .tweetNestKit, comment: "background-refresh notification body."))
                                }
                            }

                            if preferences.notifyMutingChanges, let mutingUserIDsChanges = newUserDetail.userIDsChanges(from: oldUserDetail, for: \.mutingUserIDs) {
                                if mutingUserIDsChanges.addedUserIDsCount > 0 {
                                    changes.append(String(localized: "\(mutingUserIDsChanges.addedUserIDsCount, specifier: "%ld") New Mute(s)", bundle: .tweetNestKit, comment: "background-refresh notification body."))
                                }
                                if mutingUserIDsChanges.removedUserIDsCount > 0 {
                                    changes.append(String(localized: "\(mutingUserIDsChanges.removedUserIDsCount, specifier: "%ld") New Unmute(s)", bundle: .tweetNestKit, comment: "background-refresh notification body."))
                                }
                            }

                            guard changes.isEmpty == false else {
                                return nil
                            }

                            notificationContent.body = changes.formatted(.list(type: .and, width: .narrow))

                            return UNNotificationRequest(
                                identifier: self.persistentContainer.recordID(for: userDetailObjectID)?.recordName ?? userDetailObjectID.uriRepresentation().absoluteString,
                                content: notificationContent,
                                trigger: nil
                            )
                        }

                        guard let notificationRequest = notificationRequest else { return }

                        addNotificationRequestTaskGroup.addTask {
                            do {
                                try await UNUserNotificationCenter.current().add(notificationRequest)
                            } catch {
                                self.logger.error("Error occurred while request notification: \(error as NSError, privacy: .public)")
                            }
                        }
                    case .delete:
                        let notificationIdentifiers = Array([self.persistentContainer.recordID(for: userDetailObjectID)?.recordName, userDetailObjectID.uriRepresentation().absoluteString].compacted())

                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: notificationIdentifiers)
                        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: notificationIdentifiers)
                    @unknown default:
                        break
                    }
                }

                await addNotificationRequestTaskGroup.waitForAll()
            }
        }
    }
}
