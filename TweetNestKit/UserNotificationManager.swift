//
//  UserNotificationManager.swift
//  TweetNestKit
//
//  Created by Jaehong Kang on 2022/08/12.
//

import Foundation
import CoreData
import UserNotifications
import AsyncAlgorithms
import OrderedCollections
import BackgroundTask
import UnifiedLogging
import Twitter

actor UserNotificationManager {
    private static var lastPersistentHistoryTokenData: Data? {
        get {
            TweetNestKitUserDefaults.standard.lastUserNotificationPersistentHistoryTokenData
        }
        set {
            TweetNestKitUserDefaults.standard.lastUserNotificationPersistentHistoryTokenData = newValue
        }
    }

    private static var lastPersistentHistoryToken: NSPersistentHistoryToken? {
        get throws {
            try Self.lastPersistentHistoryTokenData.flatMap {
                try NSKeyedUnarchiver.unarchivedObject(
                    ofClass: NSPersistentHistoryToken.self,
                    from: $0
                )
            }
        }
    }

    private static func setLastPersistentHistoryToken(_ newValue: NSPersistentHistoryToken?) throws {
        Self.lastPersistentHistoryTokenData = try newValue.flatMap {
            try NSKeyedArchiver.archivedData(
                withRootObject: $0,
                requiringSecureCoding: true
            )
        }
    }

    private unowned let session: Session

    private let logger = Logger(label: Bundle.tweetNestKit.bundleIdentifier!, category: String(reflecting: UserNotificationManager.self))

    private lazy var handlingPersistentStoreRemoteChangeNotificationTask = Task(priority: .high) {
        let notifiedPersistentHistoryTokens = NotificationCenter.default.notifications(
            named: .NSPersistentStoreRemoteChange,
            object: session.persistentContainer.persistentStoreCoordinator
        )
        .map { $0.userInfo?[NSPersistentHistoryTokenKey] as? NSPersistentHistoryToken }
        .removeDuplicates()

        for await persistentHistoryToken in notifiedPersistentHistoryTokens {
            await handlePersistentStoreRemoteChanges(persistentHistoryToken)
        }
    }

    private lazy var managedObjectContext = session.persistentContainer.newBackgroundContext()

    init(session: Session) {
        self.session = session

        Task {
            _ = await handlingPersistentStoreRemoteChangeNotificationTask
        }
    }

    private func handlePersistentStoreRemoteChanges(_ currentPersistentHistoryToken: NSPersistentHistoryToken?) async {
        do {
            try await withExtendedBackgroundExecution {
                guard let lastPersistentHistoryToken = try Self.lastPersistentHistoryToken else {
                    try Self.setLastPersistentHistoryToken(currentPersistentHistoryToken)

                    return
                }

                do {
                    let persistentHistoryResult = try await self.managedObjectContext.perform(schedule: .immediate) {
                        try self.managedObjectContext.execute(
                            NSPersistentHistoryChangeRequest.fetchHistory(
                                after: lastPersistentHistoryToken
                            )
                        ) as? NSPersistentHistoryResult
                    }

                    guard
                        let persistentHistoryTransactions = persistentHistoryResult?.result as? [NSPersistentHistoryTransaction],
                        let newLastPersistentHistoryToken = persistentHistoryTransactions.last?.token
                    else {
                        try Self.setLastPersistentHistoryToken(currentPersistentHistoryToken)

                        return
                    }

                    await self.handlePersistentHistoryTransactions(persistentHistoryTransactions)

                    try Self.setLastPersistentHistoryToken(newLastPersistentHistoryToken)
                } catch {
                    try? Self.setLastPersistentHistoryToken(currentPersistentHistoryToken)

                    throw error
                }
            }
        } catch {
            self.logger.error("Error occurred while handle persistent store remote changes: \(error as NSError, privacy: .public)")
        }
    }

    private func handlePersistentHistoryTransactions(_ persistentHistoryTransactions: [NSPersistentHistoryTransaction]) async {
        do {
            let changes = OrderedDictionary<NSManagedObjectID, NSPersistentHistoryChange>(
                persistentHistoryTransactions.lazy
                    .compactMap(\.changes)
                    .joined()
                    .filter { $0.changedObjectID.entity == ManagedUserDetail.entity() }
                    .map { ($0.changedObjectID, $0) },
                uniquingKeysWith: { (_, last) in last }
            )

            guard !changes.isEmpty else {
                return
            }

            async let _preferences = self.session.persistentContainer.performBackgroundTask { context in
                ManagedPreferences.managedPreferences(for: context).preferences
            }

            let (updatedObjectIDs, removedObjectIDs) = changes
                .reduce(into: ([NSManagedObjectID](), [NSManagedObjectID]())) { partialResult, change in
                    switch change.value.changeType {
                    case .insert, .update:
                        partialResult.0.append(change.key)
                    case .delete:
                        partialResult.1.append(change.key)
                    @unknown default:
                        break
                    }
                }

            let _userDetails: OrderedDictionary<NSManagedObjectID, ManagedUserDetail> = try await managedObjectContext.perform { [managedObjectContext] in
                let accountUserIDsfetchRequest = NSFetchRequest<NSDictionary>()
                accountUserIDsfetchRequest.entity = ManagedAccount.entity()
                accountUserIDsfetchRequest.resultType = .dictionaryResultType
                accountUserIDsfetchRequest.propertiesToFetch = ["userID"]
                accountUserIDsfetchRequest.returnsDistinctResults = true

                let results = try managedObjectContext.fetch(accountUserIDsfetchRequest)
                let accountUserIDs = results.compactMap {
                    $0["userID"] as? Twitter.User.ID
                }

                guard accountUserIDs.isEmpty == false else {
                    return [:]
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

                let userDetails = try managedObjectContext.fetch(userDetailsFetchRequest)

                return OrderedDictionary(
                    uniqueKeysWithValues: userDetails.map { (key: $0.objectID, value: $0) }
                )
            }

            let preferences = await _preferences

            try await withThrowingTaskGroup(of: (NSManagedObjectID?).self) { notificationTaskGroup in
                for (userDetailObjectID, _userDetail) in _userDetails {
                    notificationTaskGroup.addTask { [managedObjectContext] in
                        async let notificationContent = managedObjectContext.perform {
                            self.notificationContent(for: _userDetail, preferences: preferences, context: managedObjectContext)
                        }

                        let cloudKitRecordID = self.session.persistentContainer.recordID(for: userDetailObjectID)

                        guard let notificationContent = await notificationContent else {
                            return nil
                        }

                        try await UNUserNotificationCenter.current().add(
                            UNNotificationRequest(
                                identifier: cloudKitRecordID?.recordName ?? userDetailObjectID.uriRepresentation().absoluteString,
                                content: notificationContent,
                                trigger: nil
                            )
                        )

                        return userDetailObjectID
                    }
                }

                let needsToBeRemovedObjectIDs = try await notificationTaskGroup
                    .compactMap { $0 }
                    .reduce(into: _userDetails.keys.union(removedObjectIDs)) { partialResult, postedUserDetailObjectID in
                        partialResult.remove(postedUserDetailObjectID)
                    }

                guard !needsToBeRemovedObjectIDs.isEmpty else {
                    return
                }

                Task.detached(priority: .utility) {
                    await Task.yield()

                    do {
                        try await withExtendedBackgroundExecution {
                            let cloudKitRecordIDs = self.session.persistentContainer.recordIDs(for: needsToBeRemovedObjectIDs.elements)

                            let userNotificationIdentifiers = needsToBeRemovedObjectIDs.flatMap {
                                [cloudKitRecordIDs[$0]?.recordName, $0.uriRepresentation().absoluteString].compacted()
                            }

                            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: userNotificationIdentifiers)
                        }
                    } catch {
                        self.logger.error("Error occurred while update notifications: \(error as NSError, privacy: .public)")
                    }
                }
            }
        } catch {
            self.logger.error("Error occurred while update notifications: \(error as NSError, privacy: .public)")
        }
    }

    private nonisolated func notificationContent(
        for newUserDetail: ManagedUserDetail,
        preferences: ManagedPreferences.Preferences,
        context: NSManagedObjectContext
    ) -> UNNotificationContent? {
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
                changes.append(
                    String(localized: "New Profile", bundle: .tweetNestKit, comment: "background-refresh notification body.")
                )
            }
        }

        if preferences.notifyFollowingChanges, let followingUserIDsChanges = newUserDetail.userIDsChange(from: oldUserDetail, for: \.followingUserIDs) {
            if followingUserIDsChanges.addedUserIDs.count > 0 {
                changes.append(
                    String(
                        localized: "\(followingUserIDsChanges.addedUserIDs.count, specifier: "%ld") New Following(s)",
                        bundle: .tweetNestKit,
                        comment: "background-refresh notification body."
                    )
                )
            }
            if followingUserIDsChanges.removedUserIDs.count > 0 {
                changes.append(
                    String(
                        localized: "\(followingUserIDsChanges.removedUserIDs.count, specifier: "%ld") New Unfollowing(s)",
                        bundle: .tweetNestKit,
                        comment: "background-refresh notification body."
                    )
                )
            }
        }

        if preferences.notifyFollowerChanges, let followerUserIDsChanges = newUserDetail.userIDsChange(from: oldUserDetail, for: \.followerUserIDs) {
            if followerUserIDsChanges.addedUserIDs.count > 0 {
                changes.append(
                    String(
                        localized: "\(followerUserIDsChanges.addedUserIDs.count, specifier: "%ld") New Follower(s)",
                        bundle: .tweetNestKit,
                        comment: "background-refresh notification body."
                    )
                )
            }
            if followerUserIDsChanges.removedUserIDs.count > 0 {
                changes.append(
                    String(
                        localized: "\(followerUserIDsChanges.removedUserIDs.count, specifier: "%ld") New Unfollower(s)",
                        bundle: .tweetNestKit,
                        comment: "background-refresh notification body."
                    )
                )
            }
        }

        if preferences.notifyBlockingChanges, let blockingUserIDsChanges = newUserDetail.userIDsChange(from: oldUserDetail, for: \.blockingUserIDs) {
            if blockingUserIDsChanges.addedUserIDs.count > 0 {
                changes.append(
                    String(
                        localized: "\(blockingUserIDsChanges.addedUserIDs.count, specifier: "%ld") New Block(s)",
                        bundle: .tweetNestKit,
                        comment: "background-refresh notification body."
                    )
                )
            }
            if blockingUserIDsChanges.removedUserIDs.count > 0 {
                changes.append(
                    String(
                        localized: "\(blockingUserIDsChanges.removedUserIDs.count, specifier: "%ld") New Unblock(s)",
                        bundle: .tweetNestKit,
                        comment: "background-refresh notification body."
                    )
                )
            }
        }

        if preferences.notifyMutingChanges, let mutingUserIDsChanges = newUserDetail.userIDsChange(from: oldUserDetail, for: \.mutingUserIDs) {
            if mutingUserIDsChanges.addedUserIDs.count > 0 {
                changes.append(
                    String(
                        localized: "\(mutingUserIDsChanges.addedUserIDs.count, specifier: "%ld") New Mute(s)",
                        bundle: .tweetNestKit,
                        comment: "background-refresh notification body."
                    )
                )
            }
            if mutingUserIDsChanges.removedUserIDs.count > 0 {
                changes.append(
                    String(
                        localized: "\(mutingUserIDsChanges.removedUserIDs.count, specifier: "%ld") New Unmute(s)",
                        bundle: .tweetNestKit,
                        comment: "background-refresh notification body."
                    )
                )
            }
        }

        guard changes.isEmpty == false else {
            return nil
        }

        notificationContent.body = changes.formatted(.list(type: .and, width: .narrow))

        return notificationContent
    }
}
