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
import OrderedCollections
import UnifiedLogging

extension Session {
    private nonisolated var lastPersistentHistoryTokenURL: URL {
        PersistentContainer.defaultDirectoryURL().appendingPathComponent("TweetNestKit-Session.token")
    }
    
    private var lastPersistentHistoryToken: NSPersistentHistoryToken? {
        get {
            guard let data = try? Data(contentsOf: lastPersistentHistoryTokenURL) else {
                return nil
            }
            
            return try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSPersistentHistoryToken.self, from: data)
        }
    }

    private nonisolated var logger: Logger {
        Logger(subsystem: Bundle.module.bundleIdentifier!, category: "remote-changes")
    }

    @discardableResult
    private func updateLastPersistentHistoryToken(_ newValue: NSPersistentHistoryToken?) throws -> NSPersistentHistoryToken? {
        let lastPersistentHistoryToken = lastPersistentHistoryToken

        if let newValue = newValue {
            let data = try NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: true)
            try data.write(to: lastPersistentHistoryTokenURL)

            return lastPersistentHistoryToken
        } else {
            if FileManager.default.fileExists(atPath: lastPersistentHistoryTokenURL.path) {
                try FileManager.default.removeItem(at: lastPersistentHistoryTokenURL)
            }

            return lastPersistentHistoryToken
        }
    }

    private var persistentHistoryTransactions: (transactions: [NSPersistentHistoryTransaction], token: NSPersistentHistoryToken?, context: NSManagedObjectContext)? {
        get throws {
            let lastPersistentHistoryToken = try updateLastPersistentHistoryToken(nil)
            let fetchHistoryRequest = NSPersistentHistoryChangeRequest.fetchHistory(after: lastPersistentHistoryToken)

            let context = persistentContainer.newBackgroundContext()

            guard
                let persistentHistoryResult = try context.execute(fetchHistoryRequest) as? NSPersistentHistoryResult,
                let transactions = persistentHistoryResult.result as? [NSPersistentHistoryTransaction]
            else {
                return nil
            }

            try updateLastPersistentHistoryToken(transactions.last?.token ?? lastPersistentHistoryToken)

            return (transactions, lastPersistentHistoryToken, context)
        }
    }

    nonisolated func handlePersistentStoreRemoteChanges() {
        Task.detached(priority: .utility) { [self] in
            await withExtendedBackgroundExecution {
                do {
                    guard
                        let transactions = try await persistentHistoryTransactions,
                        let lastToken = transactions.token
                    else {
                        return
                    }

                    do {
                        try Task.checkCancellation()

                        try await withThrowingTaskGroup(of: Void.self) { taskGroup in
                            taskGroup.addTask { try await updateUserNotifications(transactions: transactions.transactions, context: transactions.context) }
                            taskGroup.addTask { try await handleAccountChanges(transactions: transactions.transactions, context: transactions.context) }
                            taskGroup.addTask { try await handleUserChanges(transactions: transactions.transactions, context: transactions.context) }

                            try await taskGroup.waitForAll()
                        }
                    } catch {
                        if error is CancellationError {
                            do {
                                try await updateLastPersistentHistoryToken(lastToken)
                            } catch {
                                logger.error("Error occurred while rollback persistent history token: \(error as NSError, privacy: .public)")
                            }
                        }

                        throw error
                    }
                } catch {
                    logger.error("Error occurred while handle persistent store remote changes: \(error as NSError, privacy: .public)")
                }
            }
        }
    }

    private nonisolated func handleAccountChanges(transactions: [NSPersistentHistoryTransaction], context: NSManagedObjectContext) async throws {
        let accountChangesByObjectID: OrderedDictionary<NSManagedObjectID, NSPersistentHistoryChange> = OrderedDictionary(
            Array(
                transactions
                    .lazy
                    .flatMap { $0.changes ?? [] }
                    .filter { $0.changedObjectID.entity.name == Account.entity().name }
                    .map { ($0.changedObjectID, $0) }
            ),
            uniquingKeysWith: { $1 }
        )

        for (accountObjectID, change) in accountChangesByObjectID {
            try Task.checkCancellation()

            func updateCredential() async {
                let credential: Twitter.Session.Credential? = await context.perform(schedule: .enqueued) {
                    guard let account = try? context.existingObject(with: accountObjectID) as? Account else {
                        return nil
                    }

                    return account.credential
                }

                guard let twitterSession = await twitterSessions[accountObjectID.uriRepresentation()] else {
                    return
                }

                await twitterSession.updateCredential(credential)
            }

            switch change.changeType {
            case .insert:
                break
            case .update:
                await updateCredential()
            case .delete:
                break
            @unknown default:
                break
            }
        }
    }

    private nonisolated func handleUserChanges(transactions: [NSPersistentHistoryTransaction], context: NSManagedObjectContext) async throws {
        let userChangesByObjectID: OrderedDictionary<NSManagedObjectID, NSPersistentHistoryChange> = OrderedDictionary(
            Array(
                transactions
                    .lazy
                    .flatMap { $0.changes ?? [] }
                    .filter { $0.changedObjectID.entity.name == User.entity().name }
                    .map { ($0.changedObjectID, $0) }
            ),
            uniquingKeysWith: { $1 }
        )

        for (userObjectID, change) in userChangesByObjectID {
            try Task.checkCancellation()

            func cleansingUser() async {
                do {
                    try await self.cleansingUser(for: userObjectID, context: context)
                } catch {
                    logger.error("Error occurred while cleansing user: \(String(reflecting: error), privacy: .public)")
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

    private nonisolated func updateUserNotifications(transactions: [NSPersistentHistoryTransaction], context: NSManagedObjectContext) async throws {
        let changesByObjectID: OrderedDictionary<NSManagedObjectID, NSPersistentHistoryChange> = OrderedDictionary(
            Array(
                transactions
                    .lazy
                    .flatMap { $0.changes ?? [] }
                    .filter { $0.changedObjectID.entity.name == UserDetail.entity().name }
                    .map { ($0.changedObjectID, $0) }
            ),
            uniquingKeysWith: { $1 }
        )

        for (userDetailObjectID, change) in changesByObjectID {
            try Task.checkCancellation()

            guard let notificationIdentifier = self.persistentContainer.record(for: userDetailObjectID)?.recordID.recordName else {
                continue
            }

            switch change.changeType {
            case .insert, .update:
                let notificationRequest: UNNotificationRequest? = await context.perform(schedule: .enqueued) {
                    guard
                        let newUserDetail = try? context.existingObject(with: userDetailObjectID) as? UserDetail,
                        (newUserDetail.creationDate ?? .distantPast) > Date(timeIntervalSinceNow: -60),
                        let user = newUserDetail.user,
                        let sortedUserDetails = user.sortedUserDetails,
                        sortedUserDetails.count > 1,
                        let account = user.account
                    else {
                        return nil
                    }

                    let oldUserDetailIndex = sortedUserDetails.lastIndex(of: newUserDetail).flatMap({ $0 - 1 })

                    let oldUserDetail = oldUserDetailIndex.flatMap { sortedUserDetails.indices.contains($0) == true ? sortedUserDetails[$0] : nil }

                    guard (oldUserDetail ~= newUserDetail) == false else {
                        return nil
                    }

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
                    notificationContent.title = notificationContentTitle

                    if let accountRecordName = self.persistentContainer.record(for: account.objectID)?.recordID.recordName {
                        notificationContent.threadIdentifier = accountRecordName
                    }

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
                        notificationContent.sound = .default
                        notificationContent.interruptionLevel = .timeSensitive
                    } else {
                        notificationContent.body = String(localized: "New Data Available", bundle: .module, comment: "background-refresh notification.")
                        notificationContent.interruptionLevel = .passive
                    }

                    return UNNotificationRequest(
                        identifier: notificationIdentifier,
                        content: notificationContent,
                        trigger: nil
                    )
                }

                guard let notificationRequest = notificationRequest else { continue }

                do {
                    try await UNUserNotificationCenter.current().add(notificationRequest)
                } catch {
                    logger.error("Error occurred while request notification: \(String(reflecting: error), privacy: .public)")
                }
            case .delete:
                UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [notificationIdentifier])
            @unknown default:
                break
            }
        }
    }
}
