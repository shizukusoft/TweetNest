//
//  Session+PersistentStoreRemoteChanges.swift
//  Session+PersistentStoreRemoteChanges
//
//  Created by Jaehong Kang on 2021/09/01.
//

import Foundation
import CoreData
import BackgroundTask

extension Session {
    private static var lastPersistentHistoryToken: NSPersistentHistoryToken? {
        get throws {
            try TweetNestKitUserDefaults.standard.lastPersistentHistoryTokenData.flatMap {
                try NSKeyedUnarchiver.unarchivedObject(
                    ofClass: NSPersistentHistoryToken.self,
                    from: $0
                )
            }
        }
    }

    private static func setLastPersistentHistoryToken(_ newValue: NSPersistentHistoryToken?) throws {
        TweetNestKitUserDefaults.standard.lastPersistentHistoryTokenData = try newValue.flatMap {
            try NSKeyedArchiver.archivedData(
                withRootObject: $0,
                requiringSecureCoding: true
            )
        }
    }

    func handlePersistentStoreRemoteChanges(_ currentPersistentHistoryToken: NSPersistentHistoryToken?, context: NSManagedObjectContext) async {
        do {
            do {
                guard let lastPersistentHistoryToken = try Self.lastPersistentHistoryToken else {
                    try Self.setLastPersistentHistoryToken(currentPersistentHistoryToken)

                    return
                }

                let persistentHistoryResult = try await withExtendedBackgroundExecution {
                    try await context.perform(schedule: .immediate) {
                        try context.execute(
                           NSPersistentHistoryChangeRequest.fetchHistory(
                               after: lastPersistentHistoryToken
                           )
                       ) as? NSPersistentHistoryResult
                    }
                }

                guard
                    let persistentHistoryTransactions = persistentHistoryResult?.result as? [NSPersistentHistoryTransaction],
                    let newLastPersistentHistoryToken = persistentHistoryTransactions.last?.token
                else {
                    try Self.setLastPersistentHistoryToken(currentPersistentHistoryToken)

                    return
                }

                Task {
                    await self.handlePersistentHistoryTransactions(persistentHistoryTransactions)
                }

                try Self.setLastPersistentHistoryToken(newLastPersistentHistoryToken)
            } catch {
                try? Self.setLastPersistentHistoryToken(currentPersistentHistoryToken)

                throw error
            }
        } catch {
            self.logger.error("Error occurred while handle persistent store remote changes: \(error as NSError, privacy: .public)")
        }
    }
}
