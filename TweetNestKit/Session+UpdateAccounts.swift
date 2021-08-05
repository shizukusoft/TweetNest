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
    public func updateAccounts() async throws -> [(NSManagedObjectID, Bool)] {
        let context = container.newBackgroundContext()

        let accountObjectIDs: [NSManagedObjectID] = try await context.perform {
            let fetchRequest = NSFetchRequest<NSManagedObjectID>(entityName: Account.entity().name!)
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(keyPath: \Account.sortOrder, ascending: true),
                NSSortDescriptor(keyPath: \Account.creationDate, ascending: true)
            ]
            fetchRequest.resultType = .managedObjectIDResultType

            return try context.fetch(fetchRequest)
        }

        return try await withThrowingTaskGroup(of: (NSManagedObjectID, Bool).self) { taskGroup in
            accountObjectIDs.forEach { accountObjectID in
                taskGroup.addTask {
                    return (accountObjectID, try await self.updateAccount(accountObjectID))
                }
            }

            return try await taskGroup.reduce(into: [], { $0.append($1) })
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
        let logger = Logger(subsystem: Bundle.module.bundleIdentifier!, category: "refresh")

        let task = Task.detached {
            logger.info("Start background task for: \(backgroundTask.identifier)")
            defer {
                logger.info("Background task finished for: \(backgroundTask.identifier)")
            }

            do {
                do {
                    try self.scheduleUpdateAccountsBackgroundTask()
                } catch {
                    logger.error("Error occured while schedule refresh: \(String(describing: error))")

                    let notificationContent = UNMutableNotificationContent()
                    notificationContent.title = "Refresh"
                    notificationContent.subtitle = "Error"
                    notificationContent.body = "Error occured while refresh.\n\n\(error.localizedDescription)"
                    notificationContent.sound = .default
                    notificationContent.interruptionLevel = .active

                    let notificationRequest = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: nil)

                    do {
                        try await UNUserNotificationCenter.current().add(notificationRequest)
                    } catch {
                        logger.error("Error occured while request notification: \(String(describing: error))")
                    }
                }

                do {
                    let changedAccountObjectIDs = try await self.updateAccounts()
                        .lazy
                        .filter { $0.1 == true }
                        .map { $0.0 }

                    let usernames: [String] = await self.container.performBackgroundTask { context in
                        changedAccountObjectIDs
                            .compactMap { context.object(with: $0) as? Account }
                            .sorted {
                                if $0.sortOrder != $1.sortOrder {
                                    return $0.sortOrder < $1.sortOrder
                                } else {
                                    return ($0.creationDate ?? .distantPast) < ($1.creationDate ?? .distantPast)
                                }
                            }
                            .map { ($0.user?.sortedUserDatas?.last?.username).flatMap { "@\($0)" } ?? "#\($0.id)"  }
                    }

                    if usernames.isEmpty == false {
                        let notificationContent = UNMutableNotificationContent()
                        notificationContent.title = "Refresh"
                        notificationContent.body = "New data available for \(usernames.joined(separator: ", "))"
                        notificationContent.interruptionLevel = .passive

                        let notificationRequest = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: nil)

                        do {
                            try await UNUserNotificationCenter.current().add(notificationRequest)
                        } catch {
                            logger.error("Error occured while request notification: \(String(describing: error))")
                        }
                    }
                } catch {
                    logger.error("Error occured while update accounts: \(String(describing: error))")

                    let notificationContent = UNMutableNotificationContent()
                    notificationContent.title = "Error"
                    notificationContent.body = error.localizedDescription
                    notificationContent.sound = .default
                    notificationContent.interruptionLevel = .active

                    let notificationRequest = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: nil)

                    do {
                        try await UNUserNotificationCenter.current().add(notificationRequest)
                    } catch {
                        logger.error("Error occured while request notification: \(String(describing: error))")
                    }

                    throw error
                }

                backgroundTask.setTaskCompleted(success: true)
            } catch {
                backgroundTask.setTaskCompleted(success: false)
            }
        }

        backgroundTask.expirationHandler = {
            logger.info("Background task expired for: \(backgroundTask.identifier)")
            task.cancel()
        }
    }
}
#endif
