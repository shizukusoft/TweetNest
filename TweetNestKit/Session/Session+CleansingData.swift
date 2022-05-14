//
//  Session+CleansingData.swift
//  Session+CleansingData
//
//  Created by Jaehong Kang on 2021/08/29.
//

import Foundation
import UserNotifications
import CoreData
import Algorithms
import OrderedCollections
import UnifiedLogging
import BackgroundTask

extension Session {
    static let cleansingDataInterval: TimeInterval = 1 * 24 * 60 * 60

    private var persistentContainerNewBackgroundContext: NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.undoManager = nil
        context.automaticallyMergesChangesFromParent = false

        return context
    }

    public func cleansingAllData(force: Bool = false) async throws {
        guard force || TweetNestKitUserDefaults.standard.lastCleansedDate.addingTimeInterval(Self.cleansingDataInterval) < Date() else {
            return
        }

        TweetNestKitUserDefaults.standard.lastCleansedDate = Date()

        try await withThrowingTaskGroup(of: Void.self) { taskGroup in
            taskGroup.addTask {
                try await self.cleansingAllAccounts(context: self.persistentContainerNewBackgroundContext)
            }

            taskGroup.addTask {
                try await self.cleansingAllUsers(context: self.persistentContainerNewBackgroundContext)
            }

            taskGroup.addTask {
                try await self.cleansingAllUserDetails(context: self.persistentContainerNewBackgroundContext)
            }

            taskGroup.addTask {
                try await self.cleansingAllUserDataAssets(context: self.persistentContainerNewBackgroundContext)
            }

            try await taskGroup.waitForAll()
        }

        try await cleansingAllPersistentStores()
    }

    public func cleansingAllAccounts(context: NSManagedObjectContext? = nil) async throws {
        let context = context ?? persistentContainerNewBackgroundContext

        let accountObjectIDs: [NSManagedObjectID] = try await context.perform {
            let fetchRequest = NSFetchRequest<NSManagedObjectID>()
            fetchRequest.entity = ManagedAccount.entity()
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(keyPath: \ManagedAccount.creationDate, ascending: false),
            ]
            fetchRequest.resultType = .managedObjectIDResultType

            return try context.fetch(fetchRequest)
        }

        for accountObjectID in accountObjectIDs {
            try Task.checkCancellation()
            try await cleansingAccount(for: accountObjectID, context: context)
        }
    }

    public func cleansingAccount(for accountObjectID: NSManagedObjectID, context: NSManagedObjectContext? = nil) async throws {
        let context = context ?? persistentContainerNewBackgroundContext

        try await context.perform(schedule: .enqueued) {
            try withExtendedBackgroundExecution {
                guard
                    let account = try? context.existingObject(with: accountObjectID) as? ManagedAccount,
                    let accountToken = account.token,
                    let accountTokenSecret = account.tokenSecret
                else {
                    return
                }

                let accountFetchRequest = ManagedAccount.fetchRequest()
                accountFetchRequest.predicate = NSCompoundPredicate(
                    andPredicateWithSubpredicates: [
                        NSPredicate(format: "token == %@", accountToken),
                        NSPredicate(format: "tokenSecret == %@", accountTokenSecret),
                    ]
                )
                accountFetchRequest.sortDescriptors = [
                    NSSortDescriptor(keyPath: \ManagedAccount.creationDate, ascending: true),
                ]
                accountFetchRequest.propertiesToFetch = ["creationDate", "preferringSortOrder", "userID", "preferences"]
                accountFetchRequest.returnsObjectsAsFaults = false

                let accounts = try context.fetch(accountFetchRequest)

                guard accounts.count > 1 else { return }

                let targetAccount = accounts.first ?? account

                targetAccount.creationDate = accounts.first?.creationDate ?? account.creationDate
                targetAccount.preferringSortOrder = accounts.first?.preferringSortOrder ?? account.preferringSortOrder
                targetAccount.userID = accounts.last?.userID ?? account.userID

                for account in accounts {
                    guard account != targetAccount else { continue }

                    targetAccount.preferences = .init(
                        fetchBlockingUsers: targetAccount.preferences.fetchBlockingUsers || account.preferences.fetchBlockingUsers
                    )

                    context.delete(account)
                }

                if context.hasChanges {
                    try context.save()
                }
            }
        }
    }

    func cleansingAllUsers(context: NSManagedObjectContext) async throws {
        let userObjectIDs: [NSManagedObjectID] = try await context.perform {
            let userFetchRequest = NSFetchRequest<NSManagedObjectID>()
            userFetchRequest.entity = ManagedUser.entity()
            userFetchRequest.resultType = .managedObjectIDResultType
            userFetchRequest.sortDescriptors = [
                NSSortDescriptor(keyPath: \ManagedUser.creationDate, ascending: true),
            ]

            return try context.fetch(userFetchRequest)
        }

        try await withThrowingTaskGroup(of: Void.self) { cleansingUserDetailsTaskGroup in
            for userObjectID in userObjectIDs {
                try Task.checkCancellation()
                try await self.cleansingUser(for: userObjectID, context: context)
            }

            try await cleansingUserDetailsTaskGroup.waitForAll()
        }
    }

    public func cleansingUser(for userObjectID: NSManagedObjectID, context: NSManagedObjectContext? = nil) async throws {
        let context = context ?? persistentContainerNewBackgroundContext

        try await context.perform(schedule: .enqueued) {
            try withExtendedBackgroundExecution {
                guard
                    let user = try? context.existingObject(with: userObjectID) as? ManagedUser,
                    let userID = user.id
                else {
                    return
                }

                let userFetchRequest = ManagedUser.fetchRequest()
                userFetchRequest.predicate = NSCompoundPredicate(
                    andPredicateWithSubpredicates: [
                        NSPredicate(format: "id == %@", userID),
                    ]
                )
                userFetchRequest.sortDescriptors = [
                    NSSortDescriptor(keyPath: \ManagedUser.creationDate, ascending: true),
                ]
                userFetchRequest.propertiesToFetch = ["creationDate", "lastUpdateEndDate", "lastUpdateStartDate"]
                userFetchRequest.relationshipKeyPathsForPrefetching = ["userDetails"]
                userFetchRequest.returnsObjectsAsFaults = false

                let users = try context.fetch(userFetchRequest)

                guard users.count > 1 else { return }

                let targetUser = users.first ?? user

                for user in users {
                    guard user != targetUser else { continue }

                    targetUser.creationDate = [targetUser.creationDate, user.creationDate].lazy.compacted().min()
                    targetUser.lastUpdateEndDate = [targetUser.lastUpdateEndDate, user.lastUpdateEndDate].lazy.compacted().max()
                    targetUser.lastUpdateStartDate = [targetUser.lastUpdateStartDate, user.lastUpdateStartDate].lazy.compacted().max()

                    context.delete(user)
                }

                if context.hasChanges {
                    try context.save()
                }
            }
        }
    }

    func cleansingAllUserDetails(context: NSManagedObjectContext) async throws {
        let userIDs: [String] = try await context.perform {
            let userIDFetchRequest = NSFetchRequest<NSDictionary>()
            userIDFetchRequest.entity = ManagedUserDetail.entity()
            userIDFetchRequest.resultType = .dictionaryResultType
            userIDFetchRequest.propertiesToFetch = [
                (\ManagedUserDetail.userID)._kvcKeyPathString!
            ]
            userIDFetchRequest.returnsDistinctResults = true

            return try context.fetch(userIDFetchRequest)
                .compactMap {
                    $0.object(forKey: "userID") as? String
                }
        }

        try await withThrowingTaskGroup(of: Void.self) { cleansingUserDetailsTaskGroup in
            for userID in userIDs {
                cleansingUserDetailsTaskGroup.addTask {
                    try await self.cleansingUserDetails(for: userID)
                }
            }

            try await cleansingUserDetailsTaskGroup.waitForAll()
        }
    }

    func cleansingUserDetails(for userID: String) async throws {
        let context = persistentContainerNewBackgroundContext

        try await context.perform(schedule: .enqueued) {
            try withExtendedBackgroundExecution {
                let fetchRequest = ManagedUserDetail.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "userID == %@", userID)
                fetchRequest.sortDescriptors = [
                    NSSortDescriptor(keyPath: \ManagedUserDetail.creationDate, ascending: true)
                ]
                fetchRequest.returnsObjectsAsFaults = false

                var userDetails = OrderedSet(try context.fetch(fetchRequest))

                for userDetail in userDetails {
                    let previousUserIndex = (userDetails.firstIndex(of: userDetail) ?? 0) - 1
                    let previousUserDetail = userDetails.indices.contains(previousUserIndex) ? userDetails[previousUserIndex] : nil

                    if previousUserDetail ~= userDetail {
                        userDetails.remove(userDetail)
                        context.delete(userDetail)
                    }
                }

                if context.hasChanges {
                    try context.save()
                }
            }
        }
    }

    func cleansingAllUserDataAssets(context: NSManagedObjectContext) async throws {
        let userDataAssetObjectIDs: [NSManagedObjectID] = try await context.perform {
            let userDataAssetsFetchRequest = NSFetchRequest<NSManagedObjectID>()
            userDataAssetsFetchRequest.entity = ManagedUserDataAsset.entity()
            userDataAssetsFetchRequest.resultType = .managedObjectIDResultType
            userDataAssetsFetchRequest.sortDescriptors = [
                NSSortDescriptor(keyPath: \ManagedUserDataAsset.creationDate, ascending: true)
            ]

            return try context.fetch(userDataAssetsFetchRequest)
        }

        for userDataAssetObjectID in userDataAssetObjectIDs {
            try Task.checkCancellation()
            try await self.cleansingUserDataAsset(for: userDataAssetObjectID, context: context)
        }
    }

    public func cleansingUserDataAsset(for userDataAssetObjectID: NSManagedObjectID, context: NSManagedObjectContext? = nil) async throws {
        let context = context ?? persistentContainerNewBackgroundContext

        try await context.perform(schedule: .enqueued) {
            guard
                let userDataAsset = try? context.existingObject(with: userDataAssetObjectID) as? ManagedUserDataAsset,
                let userDataAssetURL = userDataAsset.url,
                let userDataAssetDataSHA512Hash = userDataAsset.dataSHA512Hash
            else {
                return
            }

            let userDataAssetsFetchRequest = NSFetchRequest<NSManagedObjectID>()
            userDataAssetsFetchRequest.entity = ManagedUserDataAsset.entity()
            userDataAssetsFetchRequest.resultType = .managedObjectIDResultType
            userDataAssetsFetchRequest.predicate = NSCompoundPredicate(
                andPredicateWithSubpredicates: [
                    NSPredicate(format: "url == %@", userDataAssetURL as NSURL),
                    NSPredicate(format: "dataSHA512Hash == %@", userDataAssetDataSHA512Hash as NSData),
                ]
            )
            userDataAssetsFetchRequest.sortDescriptors = [
                NSSortDescriptor(keyPath: \ManagedUserDataAsset.creationDate, ascending: true),
            ]

            let userDataAssetObjectIDs = OrderedSet(try context.fetch(userDataAssetsFetchRequest))

            guard userDataAssetObjectIDs.count > 1 else { return }

            let targetUserDataAssetObjectID = userDataAssetObjectIDs.first ?? userDataAsset.objectID

            let batchDeleteRequest = NSBatchDeleteRequest(objectIDs: Array(userDataAssetObjectIDs.subtracting([targetUserDataAssetObjectID])))

            try context.execute(batchDeleteRequest)
        }
    }

    public func cleansingAllPersistentStores() async throws {
        let persistentContainer = persistentContainer
        let temporalPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: persistentContainer.persistentStoreCoordinator.managedObjectModel)

        for persistentStoreDescription in persistentContainer.persistentStoreDescriptions.lazy.compactMap({ $0.copy() as? NSPersistentStoreDescription }) {
            guard persistentStoreDescription.type == NSSQLiteStoreType else { return }

            persistentStoreDescription.cloudKitContainerOptions = nil
            persistentStoreDescription.setOption(nil, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
            persistentStoreDescription.setOption(true as NSNumber, forKey: NSSQLiteManualVacuumOption)
            persistentStoreDescription.setOption(true as NSNumber, forKey: NSSQLiteAnalyzeOption)

            try await persistentContainer.persistentStoreCoordinator.perform {
                try temporalPersistentStoreCoordinator.performAndWait {
                    var error: Error?

                    try withExtendedBackgroundExecution {
                        let dispatchSemaphore = DispatchSemaphore(value: 0)

                        temporalPersistentStoreCoordinator.addPersistentStore(with: persistentStoreDescription) { _, _error in
                            temporalPersistentStoreCoordinator.perform {
                                temporalPersistentStoreCoordinator.persistentStores.forEach {
                                    try? temporalPersistentStoreCoordinator.remove($0)
                                }
                            }

                            if let _error = _error {
                                error = _error
                            }

                            dispatchSemaphore.signal()
                        }

                        dispatchSemaphore.wait()
                    }

                    if let error = error {
                        throw error
                    }
                }
            }
        }
    }
}
