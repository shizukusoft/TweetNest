//
//  Session+BackgroundTask.swift
//  Session+BackgroundTask
//
//  Created by Jaehong Kang on 2021/08/29.
//

import Foundation
import CoreData
import UserNotifications
import UnifiedLogging

#if canImport(BackgroundTasks) && !os(macOS)
import BackgroundTasks
#elseif canImport(WatchKit)
import WatchKit
#endif

#if (canImport(BackgroundTasks) && !os(macOS)) || canImport(WatchKit)

extension Session {
    static var preferredBackgroundRefreshDate: Date {
        Date(timeIntervalSinceNow: 5 * 60) // Fetch no earlier than 5 minutes from now
    }
    
    public static let backgroundRefreshTaskIdentifier: String = "\(Bundle.module.bundleIdentifier!).background-refresh"
    
    #if canImport(BackgroundTasks)
    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    @discardableResult
    public nonisolated func registerAppRefreshBackgroundTask() -> Bool {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.backgroundRefreshTaskIdentifier, using: nil, launchHandler: handleBackgroundRefresh(_:))
    }
    #endif

    public nonisolated func scheduleBackgroundRefreshTask() async throws {
        #if canImport(BackgroundTasks)
        let request = BGAppRefreshTaskRequest(identifier: Self.backgroundRefreshTaskIdentifier)
        request.earliestBeginDate = Self.preferredBackgroundRefreshDate

        try BGTaskScheduler.shared.submit(request)
        #elseif canImport(WatchKit)
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Task {
                await WKExtension.shared().scheduleBackgroundRefresh(
                    withPreferredDate: Self.preferredBackgroundRefreshDate,
                    userInfo: Self.backgroundRefreshTaskIdentifier as NSString
                ) { error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume()
                    }
                }
            }
        }
        #endif
    }

    nonisolated func backgroundRefresh() async throws {
        let logger = Logger(subsystem: Bundle.module.bundleIdentifier!, category: "background-refresh")
        
        logger.info("Start background refresh")
        defer {
            logger.info("Background refresh finished")
        }
        
        do {
            try await self.scheduleBackgroundRefreshTask()
        } catch {
            logger.error("Error occurred while schedule background refresh: \(error as NSError, privacy: .public)")
        }

        do {
            let context = self.persistentContainer.newBackgroundContext()

            let accountObjectIDs: [NSManagedObjectID] = try await context.perform(schedule: .enqueued) {
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
                            let notificationContent: UNMutableNotificationContent = await context.perform(schedule: .enqueued) {
                                let account = context.object(with: accountObjectID) as? Account

                                let accountID = account?.id
                                let displayUsername = account?.user?.displayUsername ?? accountObjectID.description

                                let notificationContent = UNMutableNotificationContent()
                                notificationContent.title = String(localized: "Update accounts", bundle: .module, comment: "update-accounts notification title.")
                                notificationContent.body = String(localized: "New data available for \(displayUsername).", bundle: .module, comment: "update-accounts notification body.")
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
            case is CancellationError, URLError.cancelled:
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
    }
}
#endif

#if (canImport(BackgroundTasks) && !os(macOS))
extension Session {
    nonisolated func handleBackgroundRefresh(_ backgroundTask: BGTask) {
        let logger = Logger(subsystem: Bundle.module.bundleIdentifier!, category: "background-refresh")
        
        let task = Task { [self] in
            do {
                try await backgroundRefresh()
                
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
#elseif canImport(WatchKit)
extension Session {
    public nonisolated func handleBackgroundRefresh(_ backgroundTasks: Set<WKRefreshBackgroundTask>) -> Set<WKRefreshBackgroundTask> {
        guard let backgroundTask = backgroundTasks.first(where: { $0.userInfo as? NSString == Self.backgroundRefreshTaskIdentifier as NSString }) else {
            return []
        }
        
        let logger = Logger(subsystem: Bundle.module.bundleIdentifier!, category: "background-refresh")
        
        let task = Task { [self] in
            do {
                try await backgroundRefresh()
                
                backgroundTask.setTaskCompletedWithSnapshot(true)
            } catch {
                backgroundTask.setTaskCompletedWithSnapshot(false)
            }
        }
        
        backgroundTask.expirationHandler = {
            logger.info("Background task expired for: \(String(describing: backgroundTask.userInfo), privacy: .public)")
            task.cancel()
        }
        
        return [backgroundTask]
    }
}
#endif
