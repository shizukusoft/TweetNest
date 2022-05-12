//
//  PersistentContainer+V1.swift
//  TweetNestKit
//
//  Created by 강재홍 on 2022/05/03.
//

import Foundation
import CoreData

extension PersistentContainer {
    struct V1 {
        static var managedObjectModel: NSManagedObjectModel {
            let managedObjectModel = NSManagedObjectModel(contentsOf: Bundle.tweetNestKit.url(forResource: Bundle.tweetNestKit.name!, withExtension: "momd")!)!

            guard let accountEntity = managedObjectModel.entitiesByName["Account"] else {
                fatalError("Account entity not found.")
            }

            guard let usersFetchedPropertyDescription = accountEntity.propertiesByName["users"] as? NSFetchedPropertyDescription else {
                fatalError("users property not found in Account entity.")
            }

            usersFetchedPropertyDescription.fetchRequest?.sortDescriptors = [
                NSSortDescriptor(key: "creationDate", ascending: true),
                NSSortDescriptor(key: "modificationDate", ascending: true),
            ]

            guard let userEntity = managedObjectModel.entitiesByName["User"] else {
                fatalError("User entity not found.")
            }

            guard let accountsFetchedPropertyDescription = userEntity.propertiesByName["accounts"] as? NSFetchedPropertyDescription else {
                fatalError("accounts property not found in User entity.")
            }

            accountsFetchedPropertyDescription.fetchRequest?.sortDescriptors = [
                NSSortDescriptor(key: "creationDate", ascending: true),
            ]

            return managedObjectModel
        }

        static var defaultPersistentStoreURL: URL {
            PersistentContainer.defaultDirectoryURL().appendingPathComponent("TweetNestKit.sqlite")
        }
        static let defaultPersistentStoreConfiguration = "TweetNestKit"
        static let defaultCloudKitIdentifier = "iCloud.\(Bundle.tweetNestKit.bundleIdentifier!)"

        static var accountsPersistentStoreURL: URL {
            PersistentContainer.defaultDirectoryURL().appendingPathComponent("Accounts.sqlite")
        }
        static let accountsPersistentStoreConfiguration = "Accounts"
        static let accountsCloudKitIdentifier = "iCloud.\(Bundle.tweetNestKit.bundleIdentifier!).accounts"

        static var dataAssetsPersistentStoreURL: URL {
            PersistentContainer.defaultDirectoryURL().appendingPathComponent("DataAssets.sqlite")
        }
        static let dataAssetsPersistentStoreConfiguration = "DataAssets"
        static let dataAssetsCloudKitIdentifier = "iCloud.\(Bundle.tweetNestKit.bundleIdentifier!).dataAssets"
    }
}
