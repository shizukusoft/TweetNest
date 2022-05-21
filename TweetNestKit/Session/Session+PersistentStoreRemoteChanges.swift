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

    func handlePersistentStoreRemoteChanges(_ currentPersistentHistoryToken: NSPersistentHistoryToken?) {
        Task {
            await sessionActor.run { _ in
                do {
                    try await withExtendedBackgroundExecution {
                        do {
                            guard let lastPersistentHistoryToken = try Self.lastPersistentHistoryToken else {
                                try Self.setLastPersistentHistoryToken(currentPersistentHistoryToken)

                                return
                            }

                            let context = self.persistentContainer.newBackgroundContext()
                            let persistentHistoryResult = try await context.perform {
                                try context.execute(
                                    NSPersistentHistoryChangeRequest.fetchHistory(
                                        after: lastPersistentHistoryToken
                                    )
                                )
                            } as? NSPersistentHistoryResult

                            guard
                                let persistentHistoryTransactions = persistentHistoryResult?.result as? [NSPersistentHistoryTransaction],
                                let newLastPersistentHistoryToken = persistentHistoryTransactions.last?.token
                            else {
                                try Self.setLastPersistentHistoryToken(currentPersistentHistoryToken)

                                return
                            }

                            Task.detached {
                                await self.handlePersistentHistoryTransactions(persistentHistoryTransactions)
                            }

                            Task.detached(priority: .utility) {
                                await self.purgeOldPersistentHistories()
                            }

                            try Self.setLastPersistentHistoryToken(newLastPersistentHistoryToken)
                        } catch {
                            try? Self.setLastPersistentHistoryToken(currentPersistentHistoryToken)

                            throw error
                        }
                    }
                } catch {
                    self.logger.error("Error occurred while handle persistent store remote changes: \(error as NSError, privacy: .public)")
                }
            }
        }
    }
}

extension Session {
    private static var persistentHistoryExpiryDate: Date {
        Date(timeIntervalSinceNow: TimeInterval(exactly: -604_800)!) // Seven Days Ago
    }

    private func purgeOldPersistentHistories() async {
        do {
            let context = self.persistentContainer.newBackgroundContext()

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
