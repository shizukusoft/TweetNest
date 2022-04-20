//
//  SessionActor+RemoteChanges.swift
//  TweetNestKit
//
//  Created by 강재홍 on 2022/04/20.
//

import Foundation
import CoreData

extension SessionActor {
    @discardableResult
    func updateLastPersistentHistoryTransactionTimestamp(_ newValue: Date?) throws -> Date? {
        let oldValue = TweetNestKitUserDefaults.standard.lastPersistentHistoryTransactionTimestamp

        TweetNestKitUserDefaults.standard.lastPersistentHistoryTransactionTimestamp = newValue

        return oldValue
    }

    var persistentHistoryTransactions: (transactions: [NSPersistentHistoryTransaction], lastPersistentHistoryTransactionDate: Date?, context: NSManagedObjectContext)? {
        get throws {
            let lastPersistentHistoryTransactionDate = try updateLastPersistentHistoryTransactionTimestamp(Date())
            let fetchHistoryRequest = NSPersistentHistoryChangeRequest.fetchHistory(
                after: lastPersistentHistoryTransactionDate ?? .distantPast
            )

            let context = session.persistentContainer.newBackgroundContext()
            context.undoManager = nil

            guard
                let persistentHistoryResult = try context.performAndWait({ try context.execute(fetchHistoryRequest) }) as? NSPersistentHistoryResult,
                let transactions = persistentHistoryResult.result as? [NSPersistentHistoryTransaction]
            else {
                return nil
            }

            try updateLastPersistentHistoryTransactionTimestamp(transactions.last?.timestamp ?? lastPersistentHistoryTransactionDate)

            return (transactions, lastPersistentHistoryTransactionDate, context)
        }
    }

}
