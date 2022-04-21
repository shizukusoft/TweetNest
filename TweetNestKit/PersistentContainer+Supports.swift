//
//  PersistentContainer+Model.swift
//  TweetNestKit
//
//  Created by 강재홍 on 2022/04/21.
//

import Foundation
import CoreData

extension PersistentContainer {
    static let managedObjectModel: NSManagedObjectModel = {
        let managedObjectModel = NSManagedObjectModel(contentsOf: Bundle.tweetNestKit.url(forResource: Bundle.tweetNestKit.name!, withExtension: "momd")!)!

        guard let accountEntity = managedObjectModel.entitiesByName["Account"] else {
            fatalError("Account entity not found.")
        }

        guard let usersFetchedPropertyDescription = accountEntity.propertiesByName["users"] as? NSFetchedPropertyDescription else {
            fatalError("users property not found in Account entity.")
        }

        usersFetchedPropertyDescription.fetchRequest?.sortDescriptors = [
            NSSortDescriptor(keyPath: \User.creationDate, ascending: true),
            NSSortDescriptor(keyPath: \User.modificationDate, ascending: true),
        ]

        guard let userEntity = managedObjectModel.entitiesByName["User"] else {
            fatalError("User entity not found.")
        }

        guard let accountsFetchedPropertyDescription = userEntity.propertiesByName["accounts"] as? NSFetchedPropertyDescription else {
            fatalError("accounts property not found in User entity.")
        }

        accountsFetchedPropertyDescription.fetchRequest?.sortDescriptors = [
            NSSortDescriptor(keyPath: \Account.creationDate, ascending: true),
        ]

        return managedObjectModel
    }()

    class var defaultPersistentStoreURL: URL {
        Self.defaultDirectoryURL().appendingPathComponent("TweetNestKit.sqlite")
    }

    static let defaultPersistentStoreConfiguration = "TweetNestKit"

    class var accountsPersistentStoreURL: URL {
        Self.defaultDirectoryURL().appendingPathComponent("Accounts.sqlite")
    }

    static let accountsPersistentStoreConfiguration = "Accounts"

    class var dataAssetsPersistentStoreURL: URL {
        Self.defaultDirectoryURL().appendingPathComponent("DataAssets.sqlite")
    }

    static let dataAssetsPersistentStoreConfiguration = "DataAssets"
}
