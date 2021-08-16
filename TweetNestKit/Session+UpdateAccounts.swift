//
//  Session+UpdateAccounts.swift
//  TweetNestKit
//
//  Created by Jaehong Kang on 2021/08/04.
//

import Foundation
import CoreData
import UnifiedLogging
import BackgroundTasks
import UserNotifications

extension Session {
    @discardableResult
    public nonisolated func updateAccounts() async throws -> [(NSManagedObjectID, Result<Bool, Swift.Error>)] {
        let context = container.newBackgroundContext()

        let accountObjectIDs: [NSManagedObjectID] = try await context.perform {
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

#if os(iOS)
extension Session {
    public static let updateAccountsBackgroundTaskIdentifier: String = "\(Bundle.module.bundleIdentifier!).update-accounts"

    @available(iOSApplicationExtension, unavailable)
    @discardableResult
    public nonisolated func registerUpdateAccountsBackgroundTask() -> Bool {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.updateAccountsBackgroundTaskIdentifier, using: nil, launchHandler: updateAccounts(backgroundTask:))
    }

    public nonisolated func scheduleUpdateAccountsBackgroundTask() throws {
        let request = BGAppRefreshTaskRequest(identifier: Self.updateAccountsBackgroundTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 5 * 60) // Fetch no earlier than 5 minutes from now

        try BGTaskScheduler.shared.submit(request)
    }

    public nonisolated func updateAccounts(backgroundTask: BGTask) {
        let logger = Logger(subsystem: Bundle.module.bundleIdentifier!, category: "update-accounts")

        let task = Task.detached {
            logger.info("Start background task for: \(backgroundTask.identifier, privacy: .public)")
            defer {
                logger.info("Background task finished for: \(backgroundTask.identifier, privacy: .public)")
            }

            do {
                do {
                    try self.scheduleUpdateAccountsBackgroundTask()
                } catch {
                    logger.error("Error occurred while schedule update accounts: \(String(reflecting: error), privacy: .public)")
                }

                do {
                    let context = self.container.newBackgroundContext()

                    let accountObjectIDs: [NSManagedObjectID] = try await context.perform {
                        let fetchRequest = NSFetchRequest<NSManagedObjectID>(entityName: Account.entity().name!)
                        fetchRequest.sortDescriptors = [
                            NSSortDescriptor(keyPath: \Account.preferringSortOrder, ascending: true),
                            NSSortDescriptor(keyPath: \Account.creationDate, ascending: false)
                        ]
                        fetchRequest.resultType = .managedObjectIDResultType

                        return try context.fetch(fetchRequest)
                    }

                    try await withThrowingTaskGroup(of: Void.self) { taskGroup in
                        accountObjectIDs.forEach { accountObjectID in
                            taskGroup.addTask {
                                let hasChanges = try await self.updateAccount(accountObjectID)

                                if hasChanges {
                                    let notificationContent: UNMutableNotificationContent = await context.perform {
                                        let account = context.object(with: accountObjectID) as? Account

                                        let username = account?.user?.sortedUserDatas?.last?.username
                                        let accountID = account?.id

                                        let accountName = username.flatMap { "@\($0)" } ?? accountID.flatMap { "#\($0)" } ?? accountObjectID.description

                                        let notificationContent = UNMutableNotificationContent()
                                        notificationContent.title = String(localized: "Update accounts", bundle: .module, comment: "update-accounts notification title.")
                                        notificationContent.body = String(localized: "New data available for \(accountName).", bundle: .module, comment: "update-accounts notification body.")
                                        notificationContent.interruptionLevel = .timeSensitive
                                        notificationContent.threadIdentifier = accountID.flatMap { String($0) } ?? accountObjectID.uriRepresentation().absoluteString

                                        return notificationContent
                                    }

                                    let notificationRequest = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: nil)

                                    do {
                                        try await UNUserNotificationCenter.current().add(notificationRequest)
                                    } catch {
                                        logger.error("Error occurred while request notification: \(String(reflecting: error), privacy: .public)")
                                    }
                                }
                            }
                        }

                        try await taskGroup.waitForAll()
                    }
                } catch {
                    logger.error("Error occurred while update accounts: \(String(describing: error))")

                    switch error {
                    case is CancellationError:
                        break
                    default:
                        let notificationContent = UNMutableNotificationContent()
                        notificationContent.title = String(localized: "Update accounts", bundle: .module, comment: "update-accounts notification title.")
                        notificationContent.subtitle = String(localized: "Error", bundle: .module, comment: "update-accounts notification subtitle.")
                        notificationContent.body = error.localizedDescription
                        notificationContent.sound = .default

                        let notificationRequest = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: nil)

                        do {
                            try await UNUserNotificationCenter.current().add(notificationRequest)
                        } catch {
                            logger.error("Error occurred while request notification: \(String(reflecting: error), privacy: .public)")
                        }
                    }

                    throw error
                }

                backgroundTask.setTaskCompleted(success: true)
            } catch {
                backgroundTask.setTaskCompleted(success: false)
            }
        }

        backgroundTask.expirationHandler = {
            logger.info("Background task expired for: \(backgroundTask.identifier, privacy: .public)")
            task.cancel()
        }
    }
}
#endif
