//
//  Session+UpdateAccounts.swift
//  TweetNestKit
//
//  Created by Jaehong Kang on 2021/08/04.
//

import Foundation
import CoreData
import UnifiedLogging
import UserNotifications

extension Session {
    @discardableResult
    public nonisolated func updateAccounts() async throws -> [(NSManagedObjectID, Result<Bool, Swift.Error>)] {
        let context = persistentContainer.newBackgroundContext()

        let accountObjectIDs: [NSManagedObjectID] = try await context.perform(schedule: .enqueued) {
            let fetchRequest = NSFetchRequest<NSManagedObjectID>(entityName: Account.entity().name!)
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(keyPath: \Account.preferringSortOrder, ascending: true),
                NSSortDescriptor(keyPath: \Account.creationDate, ascending: false)
            ]
            fetchRequest.resultType = .managedObjectIDResultType

            return try context.fetch(fetchRequest)
        }

        return await withTaskGroup(of: (NSManagedObjectID, Result<Bool, Swift.Error>).self) { taskGroup in
            accountObjectIDs.forEach { accountObjectID in
                taskGroup.addTask {
                    do {
                        return try await (accountObjectID, .success(self.updateAccount(accountObjectID)))
                    } catch {
                        return (accountObjectID, .failure(error))
                    }
                }
            }

            return await taskGroup.reduce(into: [], { $0.append($1) })
        }
    }
}
