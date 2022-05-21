//
//  PersistentContainer+V3.swift
//  TweetNestKit
//
//  Created by 강재홍 on 2022/05/03.
//

import Foundation
import CoreData
import UnifiedLogging

extension PersistentContainer {
    struct V3 {
        static let managedObjectModel: NSManagedObjectModel = {
            let managedObjectModel = NSManagedObjectModel(
                contentsOf: Bundle.tweetNestKit.url(forResource: "\(Bundle.tweetNestKit.name!)V3", withExtension: "momd")!
            )!

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

        static var defaultDirectoryURL: URL {
            let defaultDirectoryURL = PersistentContainer.defaultDirectoryURL().appendingPathComponent("V3")

            if FileManager.default.fileExists(atPath: defaultDirectoryURL.path) == false {
                do {
                    try FileManager.default.createDirectory(at: defaultDirectoryURL, withIntermediateDirectories: true)
                } catch {
                    Logger(label: Bundle.tweetNestKit.bundleIdentifier!, category: String(reflecting: Self.self))
                        .error("\(error as NSError, privacy: .public)")
                }
            }

            return defaultDirectoryURL
        }

        static var defaultPersistentStoreURL: URL {
            defaultDirectoryURL.appendingPathComponent("TweetNestKit.sqlite")
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
            defaultDirectoryURL.appendingPathComponent("UserData.sqlite")
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
