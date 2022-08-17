//
//  AccountAppEntity.swift
//  TweetNestKit
//
//  Created by 강재홍 on 2022/08/09.
//

import AppIntents
import TweetNestKit
import CoreData

@available(iOSApplicationExtension 16.0, macOSApplicationExtension 13.0, watchOSApplicationExtension 9.0, *)
struct AccountAppEntitiesQuery: EntityQuery {
    func entities(for identifiers: [AccountAppEntity.ID]) async throws -> [AccountAppEntity] {
        try await Session.shared.persistentContainer.performBackgroundTask { context in
            let fetchRequest = ManagedAccount.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "SELF IN %@", identifiers)
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(keyPath: \ManagedAccount.preferringSortOrder, ascending: true),
                NSSortDescriptor(keyPath: \ManagedAccount.creationDate, ascending: false),
            ]

            let accounts = try context.fetch(fetchRequest)

            return accounts.compactMap {
                AccountAppEntity($0, context: context)
            }
        }
    }

    func suggestedEntities() async throws -> [AccountAppEntity] {
        try await Session.shared.persistentContainer.performBackgroundTask { context in
            let fetchRequest = ManagedAccount.fetchRequest()
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(keyPath: \ManagedAccount.preferringSortOrder, ascending: true),
                NSSortDescriptor(keyPath: \ManagedAccount.creationDate, ascending: false),
            ]

            let accounts = try context.fetch(fetchRequest)

            return accounts.compactMap {
                AccountAppEntity($0, context: context)
            }
        }
    }
}

@available(iOSApplicationExtension 16.0, macOSApplicationExtension 13.0, watchOSApplicationExtension 9.0, *)
struct AccountAppEntity: AppEntity, Identifiable {
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Account")
    }

    static var defaultQuery = AccountAppEntitiesQuery()

    let id: UUID

    let managedObjectID: URL
    let userID: String

    let title: String?
    let subtitle: String?
    let imageData: Data?

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(title ?? id.description)",
            subtitle: subtitle.flatMap { "\($0)" },
            image: imageData.flatMap { .init(data: $0) }
        )
    }
}

@available(iOSApplicationExtension 16, macOSApplicationExtension 13, watchOSApplicationExtension 9, *)
extension AccountAppEntity {
    init?(_ managedAccount: ManagedAccount, context: NSManagedObjectContext) {
        let imageData = try? managedAccount.users?.last?.userDetails?.last?.profileImageURL.flatMap {
            let fetchRequest = ManagedUserDataAsset.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "url == %@", $0 as NSURL)

            return try context.fetch(fetchRequest).first?.data
        }

        guard
            let persistentID = managedAccount.persistentID,
            let userID = managedAccount.userID
        else {
            return nil
        }

        self.init(
            id: persistentID,
            managedObjectID: managedAccount.objectID.uriRepresentation(),
            userID: userID,
            title: managedAccount.users?.last?.userDetails?.last?.name,
            subtitle: managedAccount.users?.last?.userDetails?.last?.displayUsername,
            imageData: imageData
        )
    }
}
