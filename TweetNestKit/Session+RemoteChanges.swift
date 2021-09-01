//
//  Session+RemoteChanges.swift
//  Session+RemoteChanges
//
//  Created by Jaehong Kang on 2021/09/01.
//

import Foundation
import CoreData
import UserNotifications
import OrderedCollections
import UnifiedLogging

extension Session {
    private nonisolated var lastPersistentHistoryTokenURL: URL {
        PersistentContainer.defaultDirectoryURL().appendingPathComponent("TweetNestKit-Session.token")
    }
    
    private nonisolated var lastPersistentHistoryToken: NSPersistentHistoryToken? {
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
    
    nonisolated func fetchChanges() {
        let lastPersistentHistoryToken = lastPersistentHistoryToken
        let fetchHistoryRequest = NSPersistentHistoryChangeRequest.fetchHistory(after: lastPersistentHistoryToken)
        
        let context = persistentContainer.newBackgroundContext()
        guard
            let historyResult = try? context.execute(fetchHistoryRequest) as? NSPersistentHistoryResult,
            let transactions = historyResult.result as? [NSPersistentHistoryTransaction]
        else {
            return
        }
        
        self.lastPersistentHistoryToken = transactions.last?.token
        
        guard lastPersistentHistoryToken != nil else {
            return
        }

        updateAccountTokens(transactions: transactions, context: context)
        updateUserNotifications(transactions: transactions, context: context)
    }
    
    private nonisolated func updateAccountTokens(transactions: [NSPersistentHistoryTransaction], context: NSManagedObjectContext) {
        let changesAccountObjectIDs: OrderedSet<NSManagedObjectID> = OrderedSet(
            transactions
                .lazy
                .compactMap { $0.changes }
                .flatMap { $0 }
                .map { $0.changedObjectID }
                .filter { $0.entity.name == Account.entity().name }
        )
        
        for accountObjectID in changesAccountObjectIDs {
            guard let account = context.object(with: accountObjectID) as? Account else {
                continue
            }
            
            let credential = account.credential
            
            Task { [self] in
                if let twitterSession = await twitterSessions[account.objectID.uriRepresentation()] {
                    await twitterSession.updateCredential(credential)
                }
            }
        }
    }
    
    private nonisolated func updateUserNotifications(transactions: [NSPersistentHistoryTransaction], context: NSManagedObjectContext) {
        let changesUserDetailObjectIDs: OrderedSet<NSManagedObjectID> = OrderedSet(
            transactions
                .lazy
                .compactMap { $0.changes }
                .flatMap { $0 }
                .filter { [.insert, .update].contains($0.changeType) }
                .map { $0.changedObjectID }
                .filter { $0.entity.name == UserDetail.entity().name }
        )
        
        for userDetailObjectID in changesUserDetailObjectIDs {
            guard
                let newUserDetail = context.object(with: userDetailObjectID) as? UserDetail,
                newUserDetail.creationDate ?? .distantPast > Date(timeIntervalSinceNow: -60),
                let user = newUserDetail.user,
                let account = user.account,
                (account.creationDate ?? .distantPast).addingTimeInterval(60) < (newUserDetail.creationDate ?? .distantPast)
            else {
                continue
            }
            
            let sortedUserDetails = newUserDetail.user?.sortedUserDetails
            let oldUserDetailIndex = sortedUserDetails?.lastIndex(of: newUserDetail).flatMap({ $0 - 1 })
            
            let oldUserDetail = oldUserDetailIndex.flatMap { sortedUserDetails?.indices.contains($0) == true ? sortedUserDetails?[$0] : nil }
            
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
            
            let notificationRequest = UNNotificationRequest(
                identifier: persistentContainer.record(for: userDetailObjectID)?.recordID.recordName ?? userDetailObjectID.uriRepresentation().absoluteString,
                content: notificationContent,
                trigger: nil
            )

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
}
