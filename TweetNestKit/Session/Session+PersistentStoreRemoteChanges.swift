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
            try await withExtendedBackgroundExecution {
                try await context.perform(schedule: .enqueued) {
                    do {
                        guard let lastPersistentHistoryToken = try Self.lastPersistentHistoryToken else {
                            try Self.setLastPersistentHistoryToken(currentPersistentHistoryToken)

                            return
                        }

                        let persistentHistoryResult = try context.execute(
                            NSPersistentHistoryChangeRequest.fetchHistory(
                                after: lastPersistentHistoryToken
                            )
                        ) as? NSPersistentHistoryResult

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

                        Task.detached(priority: .utility) {
                            await self.purgeOldPersistentHistories(context: context)
                        }
                    } catch {
                        try? Self.setLastPersistentHistoryToken(currentPersistentHistoryToken)

                        throw error
                    }
                }
            }
        } catch {
            self.logger.error("Error occurred while handle persistent store remote changes: \(error as NSError, privacy: .public)")
        }
    }
}

extension Session {
    private static var persistentHistoryExpiryDate: Date {
        Date(timeIntervalSinceNow: TimeInterval(exactly: -259_200)!) // Three Days Ago
    }

    private func purgeOldPersistentHistories(context: NSManagedObjectContext) async {
        do {
            try await withExtendedBackgroundExecution {
                try await context.perform(schedule: .enqueued) {
                    _ = try context.execute(
                        NSPersistentHistoryChangeRequest.deleteHistory(before: Self.persistentHistoryExpiryDate)
                    )
                }
            }
        } catch {
            self.logger.error("Error occurred while delete persistent histories: \(error as NSError, privacy: .public)")
        }
    }
}
