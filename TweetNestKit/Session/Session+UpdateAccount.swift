//
//  Session+UpdateAccount.swift
//  Session+UpdateAccount
//
//  Created by Jaehong Kang on 2021/08/16.
//

import Foundation
import CoreData
import UserNotifications
import UnifiedLogging
import BackgroundTask
import Twitter
import OrderedCollections

extension Session {
    @discardableResult
    public func updateAllAccounts() async throws -> [(NSManagedObjectID, Result<Bool, Swift.Error>)] {
        let context = persistentContainer.newBackgroundContext()
        context.undoManager = nil

        let accountObjectIDs: [NSManagedObjectID] = try await context.perform {
            let fetchRequest = NSFetchRequest<NSManagedObjectID>(entityName: ManagedAccount.entity().name!)
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(keyPath: \ManagedAccount.preferringSortOrder, ascending: true),
                NSSortDescriptor(keyPath: \ManagedAccount.creationDate, ascending: false),
            ]
            fetchRequest.resultType = .managedObjectIDResultType

            return try context.fetch(fetchRequest)
        }

        return await withTaskGroup(of: (NSManagedObjectID, Result<Bool, Swift.Error>).self) { taskGroup in
            accountObjectIDs.forEach { accountObjectID in
                taskGroup.addTask {
                    do {
                        let updateResults = try await self.updateAccount(accountObjectID, context: context)
                        return (accountObjectID, .success(updateResults?.oldUserDetailObjectID != updateResults?.newUserDetailObjectID))
                    } catch {
                        return (accountObjectID, .failure(error))
                    }
                }
            }

            return await taskGroup.reduce(into: [], { $0.append($1) })
        }
    }

    @discardableResult
    public func updateAccount(
        _ accountObjectID: NSManagedObjectID,
        context _context: NSManagedObjectContext? = nil
    ) async throws -> (oldUserDetailObjectID: NSManagedObjectID?, newUserDetailObjectID: NSManagedObjectID?)? {
        let context = _context ?? {
            let context = self.persistentContainer.newBackgroundContext()
            context.undoManager = nil

            return context
        }()

        let twitterSession = try await self.twitterSession(for: accountObjectID)
        let twitterAccount = try await Twitter.Account.me(session: twitterSession)

        let userID = String(twitterAccount.id)

        try await context.perform(schedule: .enqueued) {
            try withExtendedBackgroundExecution {
                guard let account = context.object(with: accountObjectID) as? ManagedAccount else {
                    return
                }

                account.userID = userID

                if account.hasChanges {
                    try context.save()
                }
            }
        }

        return try await updateUser(accountObjectID: accountObjectID, context: context)
    }
}
