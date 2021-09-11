//
//  Session+CleansingData.swift
//  Session+CleansingData
//
//  Created by Jaehong Kang on 2021/08/29.
//

import Foundation
import CoreData

extension Session {
    private nonisolated var persistentContainerNewBackgroundContext: NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.undoManager = nil
        context.automaticallyMergesChangesFromParent = false

        return context
    }

    public nonisolated func cleansingAllData() async throws {
        let context = persistentContainerNewBackgroundContext

        try await cleansingAllAccounts(context: context)
        try await cleansingAllUsersAndUserDetails(context: context)
        try await cleansingAllDataAssets(context: context)

        await preferences.lastCleansed = Date()
    }

    public nonisolated func cleansingAllAccounts(context: NSManagedObjectContext? = nil) async throws {
        let context = context ?? persistentContainerNewBackgroundContext

        let accountObjectIDs: [NSManagedObjectID] = try await context.perform(schedule: .enqueued) {
            let fetchRequest = NSFetchRequest<NSManagedObjectID>(entityName: Account.entity().name!)
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(keyPath: \Account.creationDate, ascending: false),
            ]
            fetchRequest.resultType = .managedObjectIDResultType

            return try context.fetch(fetchRequest)
        }

        for accountObjectID in accountObjectIDs {
            try Task.checkCancellation()
            try await cleansingAccount(for: accountObjectID, context: context)
        }
    }

    public nonisolated func cleansingAccount(for accountObjectID: NSManagedObjectID, context: NSManagedObjectContext? = nil) async throws {
        let context = context ?? persistentContainerNewBackgroundContext

        try await context.perform(schedule: .enqueued) {
            guard
                let account = try? context.existingObject(with: accountObjectID) as? Account,
                let accountToken = account.token
            else {
                return
            }

            let accountFetchRequest: NSFetchRequest<Account> = Account.fetchRequest()
            accountFetchRequest.predicate = NSCompoundPredicate(
                andPredicateWithSubpredicates: [
                    NSPredicate(format: "SELF != %@", account),
                    NSPredicate(format: "token == %@", accountToken),
                ]
            )
            accountFetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

            let duplicatedAccounts = try context.fetch(accountFetchRequest)

            for duplicatedAccount in duplicatedAccounts {
                account.creationDate = [account.creationDate, duplicatedAccount.creationDate].lazy.compactMap({$0}).min()
                account.preferences = .init(
                    fetchBlockingUsers: account.preferences.fetchBlockingUsers || duplicatedAccount.preferences.fetchBlockingUsers
                )
                account.token = duplicatedAccount.token
                account.tokenSecret = duplicatedAccount.tokenSecret
                account.user = [account.user, duplicatedAccount.user].lazy
                    .compactMap({$0})
                    .sorted(by: { ($0.creationDate ?? .distantFuture) < ($1.creationDate ?? .distantFuture) })
                    .first

                account.preferringSortOrder = duplicatedAccount.preferringSortOrder

                context.delete(duplicatedAccount)
            }

            try context.save()
        }
    }

    nonisolated func cleansingAllUsersAndUserDetails(context: NSManagedObjectContext) async throws {
        let userObjectIDs: [NSManagedObjectID] = try await context.perform(schedule: .enqueued) {
            let userFetchRequest = NSFetchRequest<NSManagedObjectID>(entityName: User.entity().name!)
            userFetchRequest.predicate = NSPredicate(format: "account == NULL")
            userFetchRequest.resultType = .managedObjectIDResultType
            userFetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

            return try context.fetch(userFetchRequest)
        }

        for userObjectID in userObjectIDs {
            try Task.checkCancellation()
            try await self.cleansingUser(for: userObjectID, context: context)
            try await self.cleansingUserDetails(for: userObjectID, context: context)
        }
    }

    public nonisolated func cleansingUser(for userObjectID: NSManagedObjectID, context: NSManagedObjectContext? = nil) async throws {
        let context = context ?? persistentContainerNewBackgroundContext

        try await context.perform(schedule: .enqueued) {
            guard
                let user = try? context.existingObject(with: userObjectID) as? User,
                let userID = user.id
            else {
                return
            }

            let userFetchRequest: NSFetchRequest<User> = User.fetchRequest()
            userFetchRequest.predicate = NSCompoundPredicate(
                andPredicateWithSubpredicates: [
                    NSPredicate(format: "SELF != %@", user),
                    NSPredicate(format: "id == %@", userID),
                ]
            )
            userFetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

            let duplicatedUsers = try context.fetch(userFetchRequest)

            for duplicatedUser in duplicatedUsers {
                user.account = [user.account, duplicatedUser.account].lazy
                    .compactMap({$0})
                    .sorted(by: { ($0.creationDate ?? .distantFuture) < ($1.creationDate ?? .distantFuture) })
                    .first

                user.creationDate = [user.creationDate, duplicatedUser.creationDate].lazy.compactMap({$0}).min()
                user.lastUpdateEndDate = [user.lastUpdateEndDate, duplicatedUser.lastUpdateEndDate].lazy.compactMap({$0}).max()
                user.lastUpdateStartDate = [user.lastUpdateStartDate, duplicatedUser.lastUpdateStartDate].lazy.compactMap({$0}).max()
                user.modificationDate = [user.modificationDate, duplicatedUser.modificationDate].lazy.compactMap({$0}).max()

                user.addToUserDetails(duplicatedUser.userDetails ?? [])

                context.delete(duplicatedUser)
            }

            try context.save()
        }
    }

    nonisolated func cleansingUserDetails(for userObjectID: NSManagedObjectID, context: NSManagedObjectContext? = nil) async throws {
        let context = context ?? persistentContainerNewBackgroundContext

        try await context.perform(schedule: .enqueued) {
            guard
                let user = try? context.existingObject(with: userObjectID) as? User
            else {
                return
            }

            var userDetails = user.sortedUserDetails ?? []

            for userDetail in userDetails {
                guard
                    let previousUserIndex = userDetails.firstIndex(of: userDetail).flatMap({ $0 - 1 }),
                    userDetails.indices ~= previousUserIndex
                else {
                    continue
                }

                let previousUserDetail = userDetails[previousUserIndex]

                if previousUserDetail ~= userDetail {
                    userDetails.remove(userDetail)
                    context.delete(userDetail)
                }
            }

            try context.save()
        }
    }

    nonisolated func cleansingAllDataAssets(context: NSManagedObjectContext) async throws {
        let dataAssetObjectIDs: [NSManagedObjectID] = try await context.perform(schedule: .enqueued) {
            let dataAssetsFetchRequest = NSFetchRequest<NSManagedObjectID>(entityName: DataAsset.entity().name!)
            dataAssetsFetchRequest.resultType = .managedObjectIDResultType
            dataAssetsFetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

            return try context.fetch(dataAssetsFetchRequest)
        }

        for dataAssetObjectID in dataAssetObjectIDs {
            try Task.checkCancellation()
            try await self.cleansingDataAsset(for: dataAssetObjectID, context: context)
        }
    }

    public nonisolated func cleansingDataAsset(for userObjectID: NSManagedObjectID, context: NSManagedObjectContext? = nil) async throws {
        let context = context ?? persistentContainerNewBackgroundContext

        try await context.perform(schedule: .enqueued) {
            guard
                let dataAsset = try? context.existingObject(with: userObjectID) as? DataAsset,
                let dataAssetURL = dataAsset.url,
                let dataAssetDataSHA512Hash = dataAsset.dataSHA512Hash
            else {
                return
            }

            let dataAssetsFetchRequest: NSFetchRequest<DataAsset> = DataAsset.fetchRequest()
            dataAssetsFetchRequest.predicate = NSCompoundPredicate(
                andPredicateWithSubpredicates: [
                    NSPredicate(format: "SELF != %@", dataAsset),
                    NSPredicate(format: "url == %@", dataAssetURL as NSURL),
                    NSPredicate(format: "dataSHA512Hash == %@", dataAssetDataSHA512Hash as NSData),
                ]
            )
            dataAssetsFetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

            let duplicatedDataAssets = try context.fetch(dataAssetsFetchRequest)

            for duplicatedDataAsset in duplicatedDataAssets {
                dataAsset.creationDate = [dataAsset.creationDate, duplicatedDataAsset.creationDate].lazy.compactMap({$0}).min()

                context.delete(duplicatedDataAsset)
            }

            try context.save()
        }
    }
}
