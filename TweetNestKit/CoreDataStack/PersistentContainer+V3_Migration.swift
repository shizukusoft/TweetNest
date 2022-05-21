//
//  PersistentContainer+V3_Migration.swift
//  TweetNestKit
//
//  Created by 강재홍 on 2022/05/14.
//

import Foundation
import CoreData
import CloudKit
import Algorithms
import UnifiedLogging

@available(*, deprecated) // Workaround: https://forums.swift.org/t/suppressing-deprecated-warnings/53970/6
extension PersistentContainer.V3 {
    private static func newV1PersistentContainer() -> NSPersistentContainer {
        let v1PersistentContainer = NSPersistentContainer(name: "\(Bundle.tweetNestKit.name!)", managedObjectModel: PersistentContainer.V1.managedObjectModel)
        v1PersistentContainer.persistentStoreDescriptions = [
            NSPersistentStoreDescription(url: PersistentContainer.V1.accountsPersistentStoreURL),
            NSPersistentStoreDescription(url: PersistentContainer.V1.dataAssetsPersistentStoreURL),
            NSPersistentStoreDescription(url: PersistentContainer.V1.defaultPersistentStoreURL),
        ]
        v1PersistentContainer.persistentStoreDescriptions.forEach {
            $0.type = NSSQLiteStoreType
            $0.cloudKitContainerOptions = nil
            $0.setOption(true as NSNumber, forKey: NSReadOnlyPersistentStoreOption)
            $0.setValue("EXCLUSIVE" as NSString, forPragmaNamed: "locking_mode")
        }

        return v1PersistentContainer
    }

    private static func newV3PersistentContainer() -> NSPersistentContainer {
        let v3PersistentContainer = NSPersistentContainer(name: "\(Bundle.tweetNestKit.name!).v3", managedObjectModel: managedObjectModel)
        v3PersistentContainer.persistentStoreDescriptions = [
            userDataPersistentStoreDescription,
            defaultPersistentStoreDescription,
        ]
        v3PersistentContainer.persistentStoreDescriptions.forEach {
            $0.type = NSSQLiteStoreType
            $0.cloudKitContainerOptions = nil
            $0.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        }

         return v3PersistentContainer
    }

    static func migrateFromV1() throws {
        try autoreleasepool {
            let v1PersistentContainer = newV1PersistentContainer()
            let v3PersistentContainer = newV3PersistentContainer()

            let dispatchGroup = DispatchGroup()

            var v1PersistentContainerLoadingResult: Result<Void, Error>!
            var v3PersistentContainerLoadingResult: Result<Void, Error>!

            dispatchGroup.enter()
            v1PersistentContainer.loadPersistentStores { result in
                v1PersistentContainerLoadingResult = result.mapError { $0 }
                dispatchGroup.leave()
            }

            dispatchGroup.enter()
            v3PersistentContainer.loadPersistentStores { result in
                v3PersistentContainerLoadingResult = result.mapError { $0 }
                dispatchGroup.leave()
            }

            dispatchGroup.wait()

            try v1PersistentContainerLoadingResult.get()

            do {
                try v3PersistentContainerLoadingResult.get()

                try migrateAccountsFromV1(v1PersistentContainer: v1PersistentContainer, v3PersistentContainer: v3PersistentContainer)
                try migratePreferencesFromV1(v1PersistentContainer: v1PersistentContainer, v3PersistentContainer: v3PersistentContainer)
                try migrateUsersFromV1(v1PersistentContainer: v1PersistentContainer, v3PersistentContainer: v3PersistentContainer)
                try migrateUserDetailsFromV1(v1PersistentContainer: v1PersistentContainer, v3PersistentContainer: v3PersistentContainer)
                try migrateUserDataAssetsFromV1(v1PersistentContainer: v1PersistentContainer, v3PersistentContainer: v3PersistentContainer)

                try v3PersistentContainer.persistentStoreCoordinator.performAndWait {
                    TweetNestKitUserDefaults.standard.lastPersistentHistoryTokenData = try v3PersistentContainer.persistentStoreCoordinator
                        .currentPersistentHistoryToken(
                            fromStores: v3PersistentContainer.persistentStoreCoordinator.persistentStores
                        )
                        .flatMap {
                            try NSKeyedArchiver.archivedData(withRootObject: $0, requiringSecureCoding: true)
                        }
                }
            } catch {
                try? destoryPersistentContainer(v3PersistentContainer)

                throw error
            }

            try destoryPersistentContainer(v1PersistentContainer)

            Task.detached(priority: .utility) {
                deleteV1CloudKitPrivateRecordZones()
            }
        }
    }

    private static func destoryPersistentContainer(_ persistentContainer: NSPersistentContainer) throws {
        try persistentContainer.persistentStoreCoordinator.performAndWait {
            for persistentStore in persistentContainer.persistentStoreCoordinator.persistentStores {
                guard let persistentStoreURL = persistentStore.url else {
                    continue
                }

                try persistentContainer.persistentStoreCoordinator.destroyPersistentStore(
                    at: persistentStoreURL,
                    type: NSPersistentStore.StoreType(rawValue: persistentStore.type),
                    options: [
                        NSPersistentStoreForceDestroyOption: true
                    ]
                )

                do {
                    try FileManager.default.removeItem(at: persistentStoreURL)
                } catch {
                    Logger(label: Bundle.tweetNestKit.bundleIdentifier!, category: String(reflecting: Self.self))
                        .error("\(error as NSError, privacy: .public)")
                }
            }
        }
    }

    private static func migrateAccountsFromV1(v1PersistentContainer: NSPersistentContainer, v3PersistentContainer: NSPersistentContainer) throws {
        let v1Context = v1PersistentContainer.newBackgroundContext()
        let v3Context = v3PersistentContainer.newBackgroundContext()

        try v1Context.performAndWait {
            try autoreleasepool {
                let v1AccountsFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Account")
                v1AccountsFetchRequest.fetchBatchSize = 10000
                v1AccountsFetchRequest.includesPendingChanges = false
                v1AccountsFetchRequest.returnsObjectsAsFaults = false

                let v1Accounts = try v1Context.fetch(v1AccountsFetchRequest)

                guard v1Accounts.count > 0 else { return }

                for chunkedV1Accounts in v1Accounts.chunks(ofCount: v1AccountsFetchRequest.fetchBatchSize) {
                    try v3Context.performAndWait {
                        try autoreleasepool {
                            for v1Account in chunkedV1Accounts {
                                let v3Account = NSManagedObject(entity: managedObjectModel.entitiesByName["Account"]!, insertInto: v3Context)

                                v1Account.committedValues(forKeys: nil).forEach {
                                    switch $0.key {
                                    default:
                                        v3Account.setValue($0.value is NSNull ? nil : $0.value, forKey: $0.key)
                                    }
                                }
                            }

                            try v3Context.save()
                            v3Context.reset()
                        }
                    }
                }
            }
        }
    }

    static private func migratePreferencesFromV1(v1PersistentContainer: NSPersistentContainer, v3PersistentContainer: NSPersistentContainer) throws {
        let v1Context = v1PersistentContainer.newBackgroundContext()
        let v3Context = v3PersistentContainer.newBackgroundContext()

        try v1Context.performAndWait {
            try autoreleasepool {
                let v1PreferencesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Preferences")
                v1PreferencesFetchRequest.fetchBatchSize = 10000
                v1PreferencesFetchRequest.includesPendingChanges = false
                v1PreferencesFetchRequest.returnsObjectsAsFaults = false

                let v1Preferences = try v1Context.fetch(v1PreferencesFetchRequest)

                guard v1Preferences.count > 0 else { return }

                for chunkedV1Preferences in v1Preferences.chunks(ofCount: v1PreferencesFetchRequest.fetchBatchSize) {
                    try v3Context.performAndWait {
                        try autoreleasepool {
                            for v1Preference in chunkedV1Preferences {
                                let v3Preferences = NSManagedObject(entity: managedObjectModel.entitiesByName["Preferences"]!, insertInto: v3Context)

                                v1Preference.committedValues(forKeys: nil).forEach {
                                    switch $0.key {
                                    default:
                                        v3Preferences.setValue($0.value is NSNull ? nil : $0.value, forKey: $0.key)
                                    }
                                }
                            }

                            try v3Context.save()
                            v3Context.reset()
                        }
                    }
                }
            }
        }
    }

    private static func migrateUsersFromV1(v1PersistentContainer: NSPersistentContainer, v3PersistentContainer: NSPersistentContainer) throws {
        let v1Context = v1PersistentContainer.newBackgroundContext()
        let v3Context = v3PersistentContainer.newBackgroundContext()

        try v1Context.performAndWait {
            try autoreleasepool {
                let v1UsersFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "User")
                v1UsersFetchRequest.fetchBatchSize = 10000
                v1UsersFetchRequest.includesPendingChanges = false
                v1UsersFetchRequest.returnsObjectsAsFaults = false

                let v1Users = try v1Context.fetch(v1UsersFetchRequest)

                guard v1Users.count > 0 else { return }

                for chunkedV1Users in v1Users.chunks(ofCount: v1UsersFetchRequest.fetchBatchSize) {
                    try v3Context.performAndWait {
                        try autoreleasepool {
                            for v1User in chunkedV1Users {
                                let v3User = NSManagedObject(entity: managedObjectModel.entitiesByName["User"]!, insertInto: v3Context)

                                v1User.committedValues(forKeys: nil).forEach {
                                    switch $0.key {
                                    case "modificationDate":
                                        break
                                    default:
                                        v3User.setValue($0.value is NSNull ? nil : $0.value, forKey: $0.key)
                                    }
                                }
                            }

                            try v3Context.save()
                            v3Context.reset()
                        }
                    }
                }
            }
        }
    }

    private static func migrateUserDetailsFromV1(v1PersistentContainer: NSPersistentContainer, v3PersistentContainer: NSPersistentContainer) throws {
        let v1Context = v1PersistentContainer.newBackgroundContext()
        let v3Context = v3PersistentContainer.newBackgroundContext()

        try v1Context.performAndWait {
            try autoreleasepool {
                let v1UserDetailsFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserDetail")
                v1UserDetailsFetchRequest.fetchBatchSize = 10000
                v1UserDetailsFetchRequest.includesPendingChanges = false
                v1UserDetailsFetchRequest.returnsObjectsAsFaults = false
                v1UserDetailsFetchRequest.relationshipKeyPathsForPrefetching = ["user"]

                let v1UserDetails = try v1Context.fetch(v1UserDetailsFetchRequest)

                guard v1UserDetails.count > 0 else { return }

                for chunkedV1UserDetails in v1UserDetails.chunks(ofCount: v1UserDetailsFetchRequest.fetchBatchSize) {
                    try v3Context.performAndWait {
                        try autoreleasepool {
                            for v1UserDetail in chunkedV1UserDetails {
                                let v3UserDetail = NSManagedObject(entity: managedObjectModel.entitiesByName["UserDetail"]!, insertInto: v3Context)

                                v1UserDetail.committedValues(forKeys: nil).forEach {
                                    switch $0.key {
                                    case "user":
                                        v3UserDetail.setValue(v1UserDetail.value(forKeyPath: "user.id"), forKey: "userID")
                                    default:
                                        v3UserDetail.setValue($0.value is NSNull ? nil : $0.value, forKey: $0.key)
                                    }
                                }
                            }

                            try v3Context.save()
                            v3Context.reset()
                        }
                    }
                }
            }
        }
    }

    private static func migrateUserDataAssetsFromV1(v1PersistentContainer: NSPersistentContainer, v3PersistentContainer: NSPersistentContainer) throws {
        let v1Context = v1PersistentContainer.newBackgroundContext()
        let v3Context = v3PersistentContainer.newBackgroundContext()

        try v1Context.performAndWait {
            try autoreleasepool {
                let v1DataAssetsFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DataAsset")
                v1DataAssetsFetchRequest.fetchBatchSize = 200
                v1DataAssetsFetchRequest.includesPendingChanges = false
                v1DataAssetsFetchRequest.returnsObjectsAsFaults = false

                let v1DataAssets = try v1Context.fetch(v1DataAssetsFetchRequest)

                guard v1DataAssets.count > 0 else { return }

                for chunkedV1DataAssets in v1DataAssets.chunks(ofCount: v1DataAssetsFetchRequest.fetchBatchSize) {
                    try v3Context.performAndWait {
                        try autoreleasepool {
                            for v1DataAsset in chunkedV1DataAssets {
                                let v3UserDataAsset = NSManagedObject(entity: managedObjectModel.entitiesByName["UserDataAsset"]!, insertInto: v3Context)

                                v1DataAsset.committedValues(forKeys: nil).forEach {
                                    switch $0.key {
                                    default:
                                        v3UserDataAsset.setValue($0.value is NSNull ? nil : $0.value, forKey: $0.key)
                                    }
                                }
                            }

                            try v3Context.save()
                            v3Context.reset()
                        }
                    }
                }
            }
        }
    }

    private static func deleteV1CloudKitPrivateRecordZones() {
        let containers: [CKContainer] = [
            .init(identifier: PersistentContainer.V1.defaultCloudKitIdentifier),
            .init(identifier: PersistentContainer.V1.accountsCloudKitIdentifier),
            .init(identifier: PersistentContainer.V1.dataAssetsCloudKitIdentifier),
        ]

        for container in containers {
            container.privateCloudDatabase.fetchAllRecordZones { zones, error in
                guard let zones = zones, error == nil else {
                    Logger(label: Bundle.tweetNestKit.bundleIdentifier!, category: String(reflecting: Self.self))
                        .error("Error fetching zones.")
                    return
                }

                let zoneIDs = zones.map { $0.zoneID }
                let deletionOperation = CKModifyRecordZonesOperation(recordZonesToSave: nil, recordZoneIDsToDelete: zoneIDs)

                deletionOperation.modifyRecordZonesResultBlock = { result in
                    do {
                        try result.get()
                    } catch {
                        Logger(label: Bundle.tweetNestKit.bundleIdentifier!, category: String(reflecting: Self.self))
                            .error("Error deleting records: \(error as NSError, privacy: .public)")
                    }

                }

                container.privateCloudDatabase.add(deletionOperation)
            }
        }
    }
}
