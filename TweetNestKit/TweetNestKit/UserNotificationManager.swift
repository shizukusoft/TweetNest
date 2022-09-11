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
}

extension UserNotificationManager {
    private func handlePersistentStoreRemoteChanges(_ currentPersistentHistoryToken: NSPersistentHistoryToken?) async {
        do {
            try await withExtendedBackgroundExecution {
                do {
                    guard let lastPersistentHistoryToken = try Self.lastPersistentHistoryToken else {
                        try Self.setLastPersistentHistoryToken(currentPersistentHistoryToken)

                        return
                    }

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

    private var accountsByUserID: [Twitter.User.ID: (objectID: NSManagedObjectID, persistentID: UUID?)] {
        get async throws {
            try await managedObjectContext.perform(schedule: .immediate) { [managedObjectContext] in
                let accountUserIDsfetchRequest = ManagedAccount.fetchRequest()
                accountUserIDsfetchRequest.sortDescriptors = [
                    NSSortDescriptor(keyPath: \ManagedAccount.preferringSortOrder, ascending: true),
                    NSSortDescriptor(keyPath: \ManagedAccount.creationDate, ascending: false),
                ]
                accountUserIDsfetchRequest.propertiesToFetch = ["userID", "persistentID"]
                accountUserIDsfetchRequest.returnsObjectsAsFaults = false

                let results = try managedObjectContext.fetch(accountUserIDsfetchRequest)

                return Dictionary(
                    results.lazy.compactMap {
                        guard
                            let userID = $0.userID,
                            let persistentID = $0.persistentID
                        else {
                            return nil
                        }

                        return (userID, (objectID: $0.objectID, persistentID: persistentID))
                    },
                    uniquingKeysWith: { (first, _) in first }
                )
            }
        }
    }

    private func userDetails(
        userDetailObjectIDs: some Sequence<NSManagedObjectID>,
        userIDs: some Sequence<Twitter.User.ID>
    ) async throws -> [NSManagedObjectID: ManagedUserDetail] {
        try await managedObjectContext.perform { [managedObjectContext] in
            let userDetailsFetchRequest = ManagedUserDetail.fetchRequest()
            userDetailsFetchRequest.predicate = NSCompoundPredicate(
                andPredicateWithSubpredicates: [
                    NSPredicate(format: "SELF IN %@", Array(userDetailObjectIDs)),
                    NSPredicate(format: "creationDate >= %@", Date(timeIntervalSinceNow: -(60 * 60)) as NSDate),
                    NSPredicate(format: "userID IN %@", Array(userIDs))
                ]
            )
            userDetailsFetchRequest.returnsObjectsAsFaults = false

            let userDetails = try managedObjectContext.fetch(userDetailsFetchRequest)

            return Dictionary(
                uniqueKeysWithValues: userDetails.map { (key: $0.objectID, value: $0) }
            )
        }
    }

    private func removeNotifications(for objectIDs: some Collection<NSManagedObjectID>) {
        guard !objectIDs.isEmpty else {
            return
        }

        Task.detached(priority: .utility) {
            await Task.yield()

            do {
                try await withExtendedBackgroundExecution {
                    let persistentIDs = try await self.session.persistentContainer.performBackgroundTask { context in
                        let fetchRequest = NSFetchRequest<NSDictionary>()
                        fetchRequest.entity = ManagedUserDetail.entity()
                        fetchRequest.resultType = .dictionaryResultType
                        fetchRequest.predicate = NSPredicate(format: "SELF IN %@", Array(objectIDs))
                        fetchRequest.propertiesToFetch = [
                            (\ManagedObject.persistentID)._kvcKeyPathString!
                        ]
                        fetchRequest.returnsDistinctResults = true

                        let results = try context.fetch(fetchRequest)

                        return results.compactMap { $0.value(forKey: (\ManagedObject.persistentID)._kvcKeyPathString!) as? UUID }
                    }

                    UNUserNotificationCenter.current().removeDeliveredNotifications(
                        withIdentifiers: persistentIDs.map { $0.uuidString } + objectIDs.map { $0.uriRepresentation().absoluteString }
                    )
                }
            } catch {
                self.logger.error("Error occurred while update notifications: \(error as NSError, privacy: .public)")
            }
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

            async let _accountsByUserID = accountsByUserID

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

            let accountsByUserID = try await _accountsByUserID
            guard !accountsByUserID.isEmpty else {
                return
            }

            let _userDetails = try await userDetails(userDetailObjectIDs: updatedObjectIDs, userIDs: accountsByUserID.keys)

            let preferences = await _preferences

            try await withThrowingTaskGroup(of: (NSManagedObjectID?).self) { notificationTaskGroup in
                for (userDetailObjectID, _userDetail) in _userDetails {
                    notificationTaskGroup.addTask { [managedObjectContext] in
                        let notificationRequest: UNNotificationRequest? = await managedObjectContext.perform {
                            guard
                                let userID = _userDetail.userID,
                                let account = accountsByUserID[userID]
                            else {
                                return nil
                            }

                            return self.notificationRequest(
                                for: _userDetail,
                                threadIdentifier: account.persistentID?.uuidString ?? account.objectID.uriRepresentation().absoluteString,
                                preferences: preferences,
                                context: managedObjectContext
                            )
                        }

                        guard let notificationRequest = notificationRequest else {
                            return nil
                        }

                        try await UNUserNotificationCenter.current().add(notificationRequest)

                        return userDetailObjectID
                    }
                }

                let needsToBeRemovedObjectIDs = try await notificationTaskGroup
                    .compactMap { $0 }
                    .reduce(into: Set(_userDetails.keys).union(removedObjectIDs)) { partialResult, postedUserDetailObjectID in
                        partialResult.remove(postedUserDetailObjectID)
                    }

                removeNotifications(for: needsToBeRemovedObjectIDs)
            }
        } catch {
            self.logger.error("Error occurred while update notifications: \(error as NSError, privacy: .public)")
        }
    }

    private nonisolated func notificationRequest(
        for newUserDetail: ManagedUserDetail,
        threadIdentifier: String,
        preferences: ManagedPreferences.Preferences,
        context: NSManagedObjectContext
    ) -> UNNotificationRequest? {
        guard
            let userID = newUserDetail.userID,
            let persistentID = newUserDetail.persistentID,
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
        notificationContent.threadIdentifier = threadIdentifier
        notificationContent.categoryIdentifier = "NewAccountData"
        notificationContent.sound = .default
        notificationContent.interruptionLevel = .timeSensitive

        let changeTexts =
            changeTexts(
                oldUserDetail: oldUserDetail,
                newUserDetail: newUserDetail,
                preferences: preferences)
            as [String]
        guard !changeTexts.isEmpty
        else {
            return nil
        }

        let changeText =
            changeTexts
            .map {
                String(
                    localized: "You \($0).",
                    bundle: .tweetNestKit,
                    comment: #"A notification body for background refreshing. "%@"; 'You {are followed by 2 followings, and unfollowed by a user}.'"#)
            }
            .joined()
        // TODO: routine for ko-KR postpositions
        notificationContent.body = changeText

        return UNNotificationRequest(
            identifier: persistentID.uuidString,
            content: notificationContent,
            trigger: nil
        )
    }

    private nonisolated func changeTexts(
        oldUserDetail: ManagedUserDetail,
        newUserDetail: ManagedUserDetail,
        preferences: ManagedPreferences.Preferences
    ) -> [String] {
        let categorizedChangeTexts =
            changeTexts(
                oldUserDetail: oldUserDetail,
                newUserDetail: newUserDetail,
                preferences: preferences)
            as [ChangeKind: [String]]
        var changeTexts = [String]()
        categorizedChangeTexts[.profile].flatMap({changeTexts.append(contentsOf: $0)})
        categorizedChangeTexts[.following].flatMap({changeTexts.append(contentsOf: $0)})
        categorizedChangeTexts[.follower].flatMap({changeTexts.append(contentsOf: $0)})
        categorizedChangeTexts[.muting].flatMap({changeTexts.append(contentsOf: $0)})
        categorizedChangeTexts[.blocking].flatMap({changeTexts.append(contentsOf: $0)})
        return changeTexts
    }

    private nonisolated func changeTexts(
        oldUserDetail: ManagedUserDetail,
        newUserDetail: ManagedUserDetail,
        preferences: ManagedPreferences.Preferences
    ) -> [ChangeKind: [String]] {
        var changeTexts = [ChangeKind: [String]]()
        if preferences.notifyProfileChanges {
            if !oldUserDetail.isProfileEqual(to: newUserDetail) {
                let profileChangeText =
                    String(
                        localized: "changed your profile",
                        bundle: .tweetNestKit,
                        comment: #"A part of notification body for background refreshing. "You have %@."; 'changed your profile'"#)
                changeTexts[.profile] = [_changeText(for: [profileChangeText], kind: .profile)]
            }
        }
        if preferences.notifyFollowingChanges {
            if let change =
                newUserDetail.userIDsChange(
                    from: oldUserDetail,
                    for: \.followingUserIDs,
                    component: [.followers])
            {
                changeTexts[.following] = self.changeTexts(change, for: .following)
            }
        }
        if preferences.notifyFollowerChanges {
            if let change =
                newUserDetail.userIDsChange(
                    from: oldUserDetail,
                    for: \.followerUserIDs,
                    component: [.followings])
            {
                changeTexts[.follower] = self.changeTexts(change, for: .follower)
            }
        }
        if preferences.notifyMutingChanges {
            if let change =
                newUserDetail.userIDsChange(
                    from: oldUserDetail,
                    for: \.mutingUserIDs,
                    component: [.friends, .followings, .followers, .blockings])
            {
                changeTexts[.muting] = self.changeTexts(change, for: .muting)
            }
        }
        if preferences.notifyBlockingChanges {
            if let change =
                newUserDetail.userIDsChange(
                    from: oldUserDetail,
                    for: \.blockingUserIDs,
                    component: [.friends, .followings, .followers, .mutings])
            {
                changeTexts[.blocking] = self.changeTexts(change, for: .blocking)
            }
        }
        return changeTexts
    }
}

extension UserNotificationManager {

    private enum ChangeKind: String, Equatable, Sendable {

        case profile

        case following

        case follower

        case muting

        case blocking
    }

    @inline(never)
    private nonisolated func changeTexts(
        _ change: ManagedUserDetail.DetailedUserIDsChange,
        for kind: ChangeKind
    ) -> [String] {
        guard !change.addedUserIDs.isEmpty || !change.removedUserIDs.isEmpty
        else {
            return .init()
        }
        var texts = [String]()
        var addingTexts = [String]()
        var removingTexts = [String]()
        if change.component.contains(.friends) {
            if !change.friends.addedUserIDs.isEmpty {
                addingTexts.append(_changeText(for: change.friends.addedUserIDs, component: .friends))
            }
            if !change.friends.removedUserIDs.isEmpty {
                removingTexts.append(_changeText(for: change.friends.removedUserIDs, component: .friends))
            }
        }
        if change.component.contains(.followings) {
            if !change.followings.addedUserIDs.isEmpty {
                addingTexts.append(_changeText(for: change.followings.addedUserIDs, component: .followings))
            }
            if !change.followings.removedUserIDs.isEmpty {
                removingTexts.append(_changeText(for: change.followings.removedUserIDs, component: .followings))
            }
        }
        if change.component.contains(.followers) {
            if !change.followers.addedUserIDs.isEmpty {
                addingTexts.append(_changeText(for: change.followers.addedUserIDs, component: .followers))
            }
            if !change.followers.removedUserIDs.isEmpty {
                removingTexts.append(_changeText(for: change.followers.removedUserIDs, component: .followers))
            }
        }
        if !change.others.addedUserIDs.isEmpty {
            addingTexts.append(_changeText(for: change.others.addedUserIDs, component: .init()))
        }
        if !change.others.removedUserIDs.isEmpty {
            removingTexts.append(_changeText(for: change.others.removedUserIDs, component: .init()))
        }
        if change.component.contains(.mutings) {
            if !change.uniqueMutings.addedUserIDs.isEmpty {
                addingTexts.append(_changeText(for: change.uniqueMutings.addedUserIDs, component: .mutings))
            }
            if !change.uniqueMutings.removedUserIDs.isEmpty {
                removingTexts.append(_changeText(for: change.uniqueMutings.removedUserIDs, component: .mutings))
            }
        }
        if change.component.contains(.blockings) {
            if !change.uniqueBlockings.addedUserIDs.isEmpty {
                addingTexts.append(_changeText(for: change.uniqueBlockings.addedUserIDs, component: .blockings))
            }
            if !change.uniqueBlockings.removedUserIDs.isEmpty {
                removingTexts.append(_changeText(for: change.uniqueBlockings.removedUserIDs, component: .blockings))
            }
        }
        switch kind {
        case .profile:
            break
        case .following:
            var followingTexts = [String]()
            if !addingTexts.isEmpty {
                followingTexts.append(
                    .init(
                        localized: "followed \(addingTexts.formatted(.list(type: .and, width: .standard)))",
                        bundle: .tweetNestKit,
                        comment: #"A part of notification body for background refreshing. "You have %@ and %@."; 'followed {2 followers, and a user}'"#))
            }
            if !removingTexts.isEmpty {
                followingTexts.append(
                    .init(
                        localized: "unfollowed \(removingTexts.formatted(.list(type: .and, width: .standard)))",
                        bundle: .tweetNestKit,
                        comment: #"A part of notification body for background refreshing. "You have %@ and %@."; 'unfollowed {2 followers, and a user}'"#))
            }
            texts.append(_changeText(for: followingTexts, kind: kind))
        case .follower:
            var followerTexts = [String]()
            if !addingTexts.isEmpty {
                followerTexts.append(
                    .init(
                        localized: "followed by \(addingTexts.formatted(.list(type: .and, width: .standard)))",
                        bundle: .tweetNestKit,
                        comment: #"A part of notification body for background refreshing. "You are %@ and %@."; 'followed by {2 followings, and a user}'"#))
            }
            if !removingTexts.isEmpty {
                followerTexts.append(
                    .init(
                        localized: "unfollowed by \(removingTexts.formatted(.list(type: .and, width: .standard)))",
                        bundle: .tweetNestKit,
                        comment: #"A part of notification body for background refreshing. "You are %@ and %@."; 'unfollowed by {2 followings, and a user}'"#))
            }
            texts.append(_changeText(for: followerTexts, kind: kind))
        case .muting:
            var mutingTexts = [String]()
            if !addingTexts.isEmpty {
                mutingTexts.append(
                    .init(
                        localized: "muted \(addingTexts.formatted(.list(type: .and, width: .standard)))",
                        bundle: .tweetNestKit,
                        comment: #"A part of notification body for background refreshing. "You have %@ and %@."; 'muted {2 mutual followings, and a user}'"#))
            }
            if !removingTexts.isEmpty {
                mutingTexts.append(
                    .init(
                        localized: "unmuted \(removingTexts.formatted(.list(type: .and, width: .standard)))",
                        bundle: .tweetNestKit,
                        comment: #"A part of notification body for background refreshing. "You have %@ and %@."; 'unmuted {2 mutual followings, and a user}'"#))
            }
            texts.append(_changeText(for: mutingTexts, kind: kind))
        case .blocking:
            var blockingTexts = [String]()
            if !addingTexts.isEmpty {
                blockingTexts.append(
                    .init(
                        localized: "blocked \(addingTexts.formatted(.list(type: .and, width: .standard)))",
                        bundle: .tweetNestKit,
                        comment: #"A part of notification body for background refreshing. "You have %@ and %@."; 'blocked {2 mutual followings, and a user}'"#))
            }
            if !removingTexts.isEmpty {
                blockingTexts.append(
                    .init(
                        localized: "unblocked \(removingTexts.formatted(.list(type: .and, width: .standard)))",
                        bundle: .tweetNestKit,
                        comment: #"A part of notification body for background refreshing. "You have %@ and %@."; 'unblocked {2 users, and a muted user}'"#))
            }
            texts.append(_changeText(for: blockingTexts, kind: kind))
        }
        return texts
    }

    @inline(never)
    private nonisolated func _changeText(
        for change: OrderedSet<String>,
        component: ManagedUserDetail.DetailedUserIDsChange.Component
    ) -> String {
        guard !change.isEmpty
        else {
            return .init()
        }
        if component == .friends {
            return
                .init(
                    localized: "MUTUAL_FOLLOWINGS",
                    defaultValue: "\(change.count, specifier: "%ld") mutual following(s)",
                    bundle: .tweetNestKit,
                    comment: #"A part of notification body for background refreshing. "You have unmuted %@ and %@."; '{2} mutual followings'"#)
        }
        if component == .followings {
            return
                .init(
                    localized: "FOLLOWINGS",
                    defaultValue: "\(change.count, specifier: "%ld") following(s)",
                    bundle: .tweetNestKit,
                    comment: #"A part of notification body for background refreshing. "You are followed by %@ and %@."; '{2} followings'"#)
        }
        if component == .followers {
            return
                .init(
                    localized: "FOLLOWERS",
                    defaultValue: "\(change.count, specifier: "%ld") follower(s)",
                    bundle: .tweetNestKit,
                    comment: #"A part of notification body for background refreshing. "You have followed %@ and %@."; '{2} followers'"#)
        }
        if component == .mutings {
            return
                .init(
                    localized: "MUTED_USERS",
                    defaultValue: "\(change.count, specifier: "%ld") muted user(s)",
                    bundle: .tweetNestKit,
                    comment: #"A part of notification body for background refreshing. "You have unfollowed %@ and %@."; '{2} muted users'"#)
        }
        if component == .blockings {
            return
                .init(
                    localized: "BLOCKED_USERS",
                    defaultValue: "\(change.count, specifier: "%ld") blocked user(s)",
                    bundle: .tweetNestKit,
                    comment: #"A part of notification body for background refreshing. "You have muted %@ and %@."; '{2} blocked users'"#)
        }
        return
            .init(
                localized: "USERS",
                defaultValue: "\(change.count, specifier: "%ld") user(s)",
                bundle: .tweetNestKit,
                comment: #"A part of notification body for background refreshing. "You have blocked %@ and %@."; '{2} users'"#)
    }

    @inline(never)
    private nonisolated func _changeText(
        for texts: [String],
        kind: ChangeKind
    ) -> String {
        switch kind {
        case .follower:
            if texts.count == 1 {
                return
                    .init(
                        localized: "are \(texts[0])",
                        bundle: .tweetNestKit,
                        comment: #"A part of notification body for background refreshing. "You %@."; 'are {followed by 2 users}'"#)
            }
            if texts.count == 2 {
                return
                    .init(
                        localized: "are \(texts[0]), and \(texts[1])",
                        bundle: .tweetNestKit,
                        comment: #"A notification body for background refreshing. "You %@."; becomes "You {are %@, and %@}"; 'are {followed by 2 users}, and {unfollowed by a user}'"#)
            }
        default:
            if texts.count == 1 {
                return
                    .init(
                        localized: "have \(texts[0])",
                        bundle: .tweetNestKit,
                        comment: #"A notification body for background refreshing. "You %@."; becomes "have %@"; 'have {followed 2 users}'"#)
            }
            if texts.count == 2 {
                return
                    .init(
                        localized: "have \(texts[0]), and \(texts[1])",
                        bundle: .tweetNestKit,
                        comment: #"A notification body for background refreshing. "You %@."; becomes "have %@, and %@"; 'have {followed 2 users}, and {unfollowed a user}'"#)
            }
        }
        return .init()
    }
}
