//
//  Session+PersistentHistoryTransactions.swift
//  TweetNestKit
//
//  Created by Jaehong Kang on 2022/05/20.
//

import Foundation
import Twitter
import CoreData
import CloudKit
import UserNotifications
import Algorithms
import OrderedCollections
import BackgroundTask
import UnifiedLogging

extension Session {
    func handlePersistentHistoryTransactions(_ persistentHistoryTransactions: [NSPersistentHistoryTransaction]) async {
        await withTaskGroup(of: Void.self) { taskGroup in
            taskGroup.addTask {
                await self.updateAccountCredential(transactions: persistentHistoryTransactions)
            }

            taskGroup.addTask(priority: .utility) {
                await self.cleansingAccount(transactions: persistentHistoryTransactions)
            }

            taskGroup.addTask(priority: .utility) {
                await self.cleansingUser(transactions: persistentHistoryTransactions)
            }

            taskGroup.addTask(priority: .utility) {
                await self.cleansingUserDataAssets(transactions: persistentHistoryTransactions)
            }

            await taskGroup.waitForAll()
        }
    }
}

extension Session {
    private func updateAccountCredential(transactions: [NSPersistentHistoryTransaction]) async {
        let changedAccountObjectIDs = transactions.lazy
            .compactMap(\.changes)
            .joined()
            .filter { $0.changedObjectID.entity == ManagedAccount.entity() }
            .filter { $0.changeType == .update }
            .map(\.changedObjectID)
            .uniqued()

        let context = self.persistentContainer.newBackgroundContext()
        context.undoManager = nil

        for changedAccountObjectID in changedAccountObjectIDs {
            let credential: Twitter.Session.Credential? = await context.perform {
                guard let account = context.object(with: changedAccountObjectID) as? ManagedAccount else {
                    return nil
                }

                return account.credential
            }

            guard let twitterSession = await self.sessionActor.twitterSessions[changedAccountObjectID.uriRepresentation()] else {
                return
            }

            await twitterSession.updateCredential(credential)
        }
    }
}

extension Session {
    private func cleansingAccount(transactions: [NSPersistentHistoryTransaction]) async {
        let changedAccountObjectIDs = transactions.lazy
            .compactMap(\.changes)
            .joined()
            .filter { $0.changedObjectID.entity == ManagedAccount.entity() }
            .filter { $0.changeType == .insert }
            .map(\.changedObjectID)
            .uniqued()

        let context = self.persistentContainer.newBackgroundContext()
        context.undoManager = nil

        for changedAccountObjectID in changedAccountObjectIDs {
            do {
                try await self.cleansingAccount(for: changedAccountObjectID, context: context)
            } catch {
                self.logger.error("Error occurred while cleansing account: \(error as NSError, privacy: .public)")
            }
        }
    }

    private func cleansingUser(transactions: [NSPersistentHistoryTransaction]) async {
        let changedUserObjectIDs = transactions.lazy
            .compactMap(\.changes)
            .joined()
            .filter { $0.changedObjectID.entity == ManagedUser.entity() }
            .filter { $0.changeType == .insert }
            .map(\.changedObjectID)
            .uniqued()

        let context = self.persistentContainer.newBackgroundContext()
        context.undoManager = nil

        for changedUserObjectID in changedUserObjectIDs {
            do {
                try await self.cleansingUser(for: changedUserObjectID, context: context)
            } catch {
                self.logger.error("Error occurred while cleansing user: \(error as NSError, privacy: .public)")
            }
        }
    }

    private func cleansingUserDataAssets(transactions: [NSPersistentHistoryTransaction]) async {
        let changedUserDataAssetObjectIDs = transactions.lazy
            .compactMap(\.changes)
            .joined()
            .filter { $0.changedObjectID.entity == ManagedUserDataAsset.entity() }
            .filter { $0.changeType == .insert }
            .map(\.changedObjectID)
            .uniqued()

        let context = self.persistentContainer.newBackgroundContext()
        context.undoManager = nil

        for changedUserDataAssetObjectID in changedUserDataAssetObjectIDs {
            do {
                try await self.cleansingUserDataAsset(for: changedUserDataAssetObjectID, context: context)
            } catch {
                self.logger.error("Error occurred while cleansing data asset: \(error as NSError, privacy: .public)")
            }
        }
    }
}
