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
        set {
            guard let newValue = newValue else {
                try? FileManager.default.removeItem(at: lastPersistentHistoryTokenURL)
                return
            }
            
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: true) else {
                return
            }
            
            try? data.write(to: lastPersistentHistoryTokenURL)
        }
    }

    @discardableResult
    private func updateLastPersistentHistoryToken(_ newValue: NSPersistentHistoryToken?) -> NSPersistentHistoryToken? {
        let lastPersistentHistoryToken = lastPersistentHistoryToken
        self.lastPersistentHistoryToken = newValue

        return lastPersistentHistoryToken
    }

    private var persistentHistoryTransactions: (transactions: [NSPersistentHistoryTransaction], token: NSPersistentHistoryToken?, context: NSManagedObjectContext)? {
        let lastPersistentHistoryToken = updateLastPersistentHistoryToken(nil)
        let fetchHistoryRequest = NSPersistentHistoryChangeRequest.fetchHistory(after: lastPersistentHistoryToken)

        let context = persistentContainer.newBackgroundContext()

        guard
            let persistentHistoryResult = try? context.execute(fetchHistoryRequest) as? NSPersistentHistoryResult,
            let transactions = persistentHistoryResult.result as? [NSPersistentHistoryTransaction]
        else {
            return nil
        }

        updateLastPersistentHistoryToken(transactions.last?.token ?? lastPersistentHistoryToken)

        return (transactions, lastPersistentHistoryToken, context)
    }

    nonisolated func fetchChanges() {
        Task { [self] in
            await withExtendedBackgroundExecution {
                guard
                    let transactions = await persistentHistoryTransactions,
                    transactions.token != nil
                else {
                    return
                }

                await withTaskGroup(of: Void.self) { taskGroup in
                    taskGroup.addTask { await updateUserNotifications(transactions: transactions.transactions, context: transactions.context) }
                    taskGroup.addTask { await updateAccountTokens(transactions: transactions.transactions, context: transactions.context) }

                    await taskGroup.waitForAll()
                }
            }
        }
    }
    
    private nonisolated func updateAccountTokens(transactions: [NSPersistentHistoryTransaction], context: NSManagedObjectContext) async {
        let changesAccountObjectIDs: OrderedSet<NSManagedObjectID> = OrderedSet(
            transactions
                .lazy
                .compactMap { $0.changes }
                .flatMap { $0 }
                .map { $0.changedObjectID }
                .filter { $0.entity.name == Account.entity().name }
        )
        
        for accountObjectID in changesAccountObjectIDs {
            let credential: Twitter.Session.Credential? = await context.perform(schedule: .enqueued) {
                guard let account = try? context.existingObject(with: accountObjectID) as? Account else {
                    return nil
                }

                return account.credential
            }

            guard let twitterSession = await twitterSessions[accountObjectID.uriRepresentation()] else {
                continue
            }
            
            await twitterSession.updateCredential(credential)
        }
    }
    
    private nonisolated func updateUserNotifications(transactions: [NSPersistentHistoryTransaction], context: NSManagedObjectContext) async {
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
                        let account = user.account,
                        (account.creationDate ?? .distantPast).addingTimeInterval(60) < (newUserDetail.creationDate ?? .distantPast)
                    else {
                        return nil
                    }

                    let sortedUserDetails = newUserDetail.user?.sortedUserDetails
                    let oldUserDetailIndex = sortedUserDetails?.lastIndex(of: newUserDetail).flatMap({ $0 - 1 })

                    let oldUserDetail = oldUserDetailIndex.flatMap { sortedUserDetails?.indices.contains($0) == true ? sortedUserDetails?[$0] : nil }

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

                guard let notificationRequest = notificationRequest else { return }

                do {
                    try await UNUserNotificationCenter.current().add(notificationRequest)
                } catch {
                    Logger(subsystem: Bundle.module.bundleIdentifier!, category: "update-account")
                        .error("Error occurred while request notification: \(String(reflecting: error), privacy: .public)")
                }
            case .delete:
                UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [notificationIdentifier])
            @unknown default:
                break
            }
        }
    }
}
