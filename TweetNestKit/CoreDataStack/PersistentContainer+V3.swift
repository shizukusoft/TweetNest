//
//  PersistentContainer+V3.swift
//  TweetNestKit
//
//  Created by 강재홍 on 2022/05/03.
//

import Foundation
import CoreData
import CloudKit
import Algorithms
import UnifiedLogging

extension PersistentContainer {
    struct V3 {
        static let managedObjectModel: NSManagedObjectModel = {
            let managedObjectModel = NSManagedObjectModel(contentsOf: Bundle.tweetNestKit.url(forResource: "\(Bundle.tweetNestKit.name!)V3", withExtension: "momd")!)!

            guard let accountEntity = managedObjectModel.entitiesByName["Account"] else {
                fatalError("Account entity not found.")
            }

            guard let accountEntityUsersFetchedPropertyDescription = accountEntity.propertiesByName["users"] as? NSFetchedPropertyDescription else {
                fatalError("users property not found in Account entity.")
            }

            accountEntityUsersFetchedPropertyDescription.fetchRequest?.sortDescriptors = [
                NSSortDescriptor(key: "creationDate", ascending: true)
            ]

            guard let userEntity = managedObjectModel.entitiesByName["User"] else {
                fatalError("User entity not found.")
            }

            guard let userEntityAccountsFetchedPropertyDescription = userEntity.propertiesByName["accounts"] as? NSFetchedPropertyDescription else {
                fatalError("accounts property not found in User entity.")
            }

            userEntityAccountsFetchedPropertyDescription.fetchRequest?.sortDescriptors = [
                NSSortDescriptor(key: "creationDate", ascending: true)
            ]

            guard let userEntityUserDetailsFetchedPropertyDescription = userEntity.propertiesByName["userDetails"] as? NSFetchedPropertyDescription else {
                fatalError("userDetails property not found in User entity.")
            }

            userEntityUserDetailsFetchedPropertyDescription.fetchRequest?.sortDescriptors = [
                NSSortDescriptor(key: "creationDate", ascending: true)
            ]

            guard let userDetailEntity = managedObjectModel.entitiesByName["UserDetail"] else {
                fatalError("UserDetail entity not found.")
            }

            guard let userDetailEntityUsersFetchedPropertyDescription = userDetailEntity.propertiesByName["users"] as? NSFetchedPropertyDescription else {
                fatalError("users property not found in UserDetail entity.")
            }

            userDetailEntityUsersFetchedPropertyDescription.fetchRequest?.sortDescriptors = [
                NSSortDescriptor(key: "creationDate", ascending: true)
            ]

            return managedObjectModel
        }()

        static var defaultPersistentStoreURL: URL {
            PersistentContainer.defaultDirectoryURL().appendingPathComponent("V3").appendingPathComponent("TweetNestKit.sqlite")
        }
        static let defaultPersistentStoreConfiguration = "TweetNestKit"
        static let defaultCloudKitIdentifier = "iCloud.\(Bundle.tweetNestKit.bundleIdentifier!).v3"
        static var defaultPersistentStoreDescription: NSPersistentStoreDescription {
            let persistentStoreDescription = NSPersistentStoreDescription(url: Self.defaultPersistentStoreURL)
            persistentStoreDescription.configuration = Self.defaultPersistentStoreConfiguration
            persistentStoreDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: Self.defaultCloudKitIdentifier)

            return persistentStoreDescription
        }

        static var userDataPersistentStoreURL: URL {
            PersistentContainer.defaultDirectoryURL().appendingPathComponent("V3").appendingPathComponent("UserData.sqlite")
        }
        static let userDataPersistentStoreConfiguration = "UserData"
        static let userDataCloudKitIdentifier = "iCloud.\(Bundle.tweetNestKit.bundleIdentifier!).v3.userData"
        static var userDataPersistentStoreDescription: NSPersistentStoreDescription {
            let persistentStoreDescription = NSPersistentStoreDescription(url: Self.userDataPersistentStoreURL)
            persistentStoreDescription.configuration = Self.userDataPersistentStoreConfiguration
            persistentStoreDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: Self.userDataCloudKitIdentifier)

            return persistentStoreDescription
        }
    }
}

@available(*, deprecated) // Workaround: https://forums.swift.org/t/suppressing-deprecated-warnings/53970/6
extension PersistentContainer.V3 {
    static func migrateFromV1() throws {
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
        }

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

        v1PersistentContainer.loadPersistentStores { _, _ in }
        v3PersistentContainer.loadPersistentStores { _, _ in }

        try migrateAccountsFromV1(v1PersistentContainer: v1PersistentContainer, v3PersistentContainer: v3PersistentContainer)
        try migratePreferencesFromV1(v1PersistentContainer: v1PersistentContainer, v3PersistentContainer: v3PersistentContainer)
        try migrateUsersFromV1(v1PersistentContainer: v1PersistentContainer, v3PersistentContainer: v3PersistentContainer)
        try migrateUserDetailsFromV1(v1PersistentContainer: v1PersistentContainer, v3PersistentContainer: v3PersistentContainer)
        try migrateUserDataAssetsFromV1(v1PersistentContainer: v1PersistentContainer, v3PersistentContainer: v3PersistentContainer)

        try v1PersistentContainer.persistentStoreDescriptions.forEach {
            try v1PersistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: $0.url!, ofType: $0.type)
        }

        TweetNestKitUserDefaults.standard.lastPersistentHistoryTokenData = v3PersistentContainer.persistentStoreCoordinator.currentPersistentHistoryToken(fromStores: nil)
            .flatMap {
                try? NSKeyedArchiver.archivedData(
                    withRootObject: $0,
                    requiringSecureCoding: true
                )
            }

        Task.detached(priority: .utility) {
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

    private static func migrateAccountsFromV1(v1PersistentContainer: NSPersistentContainer, v3PersistentContainer: NSPersistentContainer) throws {
        let v1Context = v1PersistentContainer.newBackgroundContext()
        let v3Context = v3PersistentContainer.newBackgroundContext()

        try v1Context.performAndWait {
            let v1AccountsFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Account")
            v1AccountsFetchRequest.fetchBatchSize = 10000
            v1AccountsFetchRequest.returnsObjectsAsFaults = false

            let v1Accounts = try v1Context.fetch(v1AccountsFetchRequest)

            guard v1Accounts.count > 1 else { return }

            for chunkedV1Accounts in v1Accounts.chunks(ofCount: v1AccountsFetchRequest.fetchBatchSize) {
                let v3AccountsBatchInsertRequest = NSBatchInsertRequest(
                    entity: ManagedAccount.entity(),
                    objects: chunkedV1Accounts.map { v1Account in
                        [
                            "creationDate": v1Account.value(forKey: "creationDate") as Any,
                            "preferringSortOrder": v1Account.value(forKey: "preferringSortOrder") as Any,
                            "token": v1Account.value(forKey: "token") as Any,
                            "tokenSecret": v1Account.value(forKey: "tokenSecret") as Any,
                            "userID": v1Account.value(forKey: "userID") as Any,
                            "preferences": v1Account.value(forKey: "preferences") as Any
                        ]
                    }
                )

                try v3Context.performAndWait {
                    _ = try v3Context.execute(v3AccountsBatchInsertRequest)
                }

                chunkedV1Accounts.forEach { v1Context.refresh($0, mergeChanges: false) }
            }
        }
    }

    static private func migratePreferencesFromV1(v1PersistentContainer: NSPersistentContainer, v3PersistentContainer: NSPersistentContainer) throws {
        let v1Context = v1PersistentContainer.newBackgroundContext()
        let v3Context = v3PersistentContainer.newBackgroundContext()

        try v1Context.performAndWait {
            let v1PreferencesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Preferences")
            v1PreferencesFetchRequest.fetchBatchSize = 10000
            v1PreferencesFetchRequest.returnsObjectsAsFaults = false

            let v1Preferences = try v1Context.fetch(v1PreferencesFetchRequest)

            guard v1Preferences.count > 1 else { return }

            for chunkedV1Preferences in v1Preferences.chunks(ofCount: v1PreferencesFetchRequest.fetchBatchSize) {
                let v3PreferencesBatchInsertRequest = NSBatchInsertRequest(
                    entity: ManagedPreferences.entity(),
                    objects: chunkedV1Preferences.map { v1Preference in
                        [
                            "modificationDate": v1Preference.value(forKey: "modificationDate") as Any,
                            "preferences": v1Preference.value(forKey: "preferences") as Any
                        ]
                    }
                )

                try v3Context.performAndWait {
                    _ = try v3Context.execute(v3PreferencesBatchInsertRequest)
                }

                chunkedV1Preferences.forEach { v1Context.refresh($0, mergeChanges: false) }
            }
        }
    }

    private static func migrateUsersFromV1(v1PersistentContainer: NSPersistentContainer, v3PersistentContainer: NSPersistentContainer) throws {
        let v1Context = v1PersistentContainer.newBackgroundContext()
        let v3Context = v3PersistentContainer.newBackgroundContext()

        try v1Context.performAndWait {
            let v1UsersFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "User")
            v1UsersFetchRequest.fetchBatchSize = 10000
            v1UsersFetchRequest.returnsObjectsAsFaults = false

            let v1Users = try v1Context.fetch(v1UsersFetchRequest)

            guard v1Users.count > 1 else { return }

            for chunkedV1Users in v1Users.chunks(ofCount: v1UsersFetchRequest.fetchBatchSize) {
                let v3UsersBatchInsertRequest = NSBatchInsertRequest(
                    entity: ManagedUser.entity(),
                    objects: chunkedV1Users.map { v1User in
                        [
                            "creationDate": v1User.value(forKey: "creationDate") as Any,
                            "id": v1User.value(forKey: "id") as Any,
                            "lastUpdateEndDate": v1User.value(forKey: "lastUpdateEndDate") as Any,
                            "lastUpdateStartDate": v1User.value(forKey: "lastUpdateStartDate") as Any,
                        ]
                    }
                )

                try v3Context.performAndWait {
                    _ = try v3Context.execute(v3UsersBatchInsertRequest)
                }

                chunkedV1Users.forEach { v1Context.refresh($0, mergeChanges: false) }
            }
        }
    }

    private static func migrateUserDetailsFromV1(v1PersistentContainer: NSPersistentContainer, v3PersistentContainer: NSPersistentContainer) throws {
        let v1Context = v1PersistentContainer.newBackgroundContext()
        let v3Context = v3PersistentContainer.newBackgroundContext()

        try v1Context.performAndWait {
            let v1UserDetailsFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserDetail")
            v1UserDetailsFetchRequest.fetchBatchSize = 10000
            v1UserDetailsFetchRequest.returnsObjectsAsFaults = false

            let v1UserDetails = try v1Context.fetch(v1UserDetailsFetchRequest)

            guard v1UserDetails.count > 1 else { return }

            for chunkedV1UserDetails in v1UserDetails.chunks(ofCount: v1UserDetailsFetchRequest.fetchBatchSize) {
                let v3UserDetailsBatchInsertRequest = NSBatchInsertRequest(
                    entity: ManagedUserDetail.entity(),
                    objects: chunkedV1UserDetails.map { v1UserDetail in
                        [
                            "blockingUserIDs": v1UserDetail.value(forKey: "blockingUserIDs") as Any,
                            "creationDate": v1UserDetail.value(forKey: "creationDate") as Any,
                            "followerUserIDs": v1UserDetail.value(forKey: "followerUserIDs") as Any,
                            "followerUsersCount": v1UserDetail.value(forKey: "followerUsersCount") as Any,
                            "followingUserIDs": v1UserDetail.value(forKey: "followingUserIDs") as Any,
                            "followingUsersCount": v1UserDetail.value(forKey: "followingUsersCount") as Any,
                            "isProtected": v1UserDetail.value(forKey: "isProtected") as Any,
                            "isVerified": v1UserDetail.value(forKey: "isVerified") as Any,
                            "listedCount": v1UserDetail.value(forKey: "listedCount") as Any,
                            "location": v1UserDetail.value(forKey: "location") as Any,
                            "mutingUserIDs": v1UserDetail.value(forKey: "mutingUserIDs") as Any,
                            "name": v1UserDetail.value(forKey: "name") as Any,
                            "profileHeaderImageURL": v1UserDetail.value(forKey: "profileHeaderImageURL") as Any,
                            "profileImageURL": v1UserDetail.value(forKey: "profileImageURL") as Any,
                            "tweetsCount": v1UserDetail.value(forKey: "tweetsCount") as Any,
                            "url": v1UserDetail.value(forKey: "url") as Any,
                            "userAttributedDescription": v1UserDetail.value(forKey: "userAttributedDescription") as Any,
                            "userCreationDate": v1UserDetail.value(forKey: "userCreationDate") as Any,
                            "userID": v1UserDetail.value(forKeyPath: "user.id") as Any,
                            "username": v1UserDetail.value(forKey: "username") as Any,
                        ]
                    }
                )

                try v3Context.performAndWait {
                    _ = try v3Context.execute(v3UserDetailsBatchInsertRequest)
                }

                chunkedV1UserDetails.forEach { v1Context.refresh($0, mergeChanges: false) }
            }
        }
    }

    private static func migrateUserDataAssetsFromV1(v1PersistentContainer: NSPersistentContainer, v3PersistentContainer: NSPersistentContainer) throws {
        let v1Context = v1PersistentContainer.newBackgroundContext()
        let v3Context = v3PersistentContainer.newBackgroundContext()

        try v1Context.performAndWait {
            let v1DataAssetsFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DataAsset")
            v1DataAssetsFetchRequest.fetchBatchSize = 200
            v1DataAssetsFetchRequest.returnsObjectsAsFaults = false

            let v1DataAssets = try v1Context.fetch(v1DataAssetsFetchRequest)

            guard v1DataAssets.count > 1 else { return }

            for chunkedV1DataAssets in v1DataAssets.chunks(ofCount: v1DataAssetsFetchRequest.fetchBatchSize) {
                let v3UserDataAssetsInsertRequest = NSBatchInsertRequest(
                    entity: ManagedUserDataAsset.entity(),
                    objects: chunkedV1DataAssets.map { v1DataAsset in
                        [
                            "creationDate": v1DataAsset.value(forKey: "creationDate") as Any,
                            "data": v1DataAsset.value(forKey: "data") as Any,
                            "dataMIMEType": v1DataAsset.value(forKey: "dataMIMEType") as Any,
                            "dataSHA512Hash": v1DataAsset.value(forKey: "dataSHA512Hash") as Any,
                            "url": v1DataAsset.value(forKey: "url") as Any,
                        ]
                    }
                )

                try v3Context.performAndWait {
                    _ = try v3Context.execute(v3UserDataAssetsInsertRequest)
                }

                chunkedV1DataAssets.forEach { v1Context.refresh($0, mergeChanges: false) }
            }
        }
    }
}
