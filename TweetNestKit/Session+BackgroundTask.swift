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
    
    public static let backgroundRefreshBackgroundTaskIdentifier: String = "\(Bundle.module.bundleIdentifier!).background-refresh"
    
    #if canImport(BackgroundTasks) && !os(macOS)
    public static let dataCleansingBackgroundTaskIdentifier: String = "\(Bundle.module.bundleIdentifier!).data-cleansing"
    
    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    @discardableResult
    public nonisolated func registerBackgroundTasks() -> Bool {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.backgroundRefreshBackgroundTaskIdentifier, using: nil, launchHandler: handleBackgroundRefreshBackgroundTask(_:)) &&
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.dataCleansingBackgroundTaskIdentifier, using: nil, launchHandler: handleDataCleansingBackgroundTask(_:))
    }
    #endif

    public nonisolated func scheduleBackgroundRefreshTask() async throws {
        #if canImport(BackgroundTasks) && !os(macOS)
        let request = BGAppRefreshTaskRequest(identifier: Self.backgroundRefreshBackgroundTaskIdentifier)
        request.earliestBeginDate = Self.preferredBackgroundRefreshDate

        try BGTaskScheduler.shared.submit(request)
        #elseif canImport(WatchKit)
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Task {
                await WKExtension.shared().scheduleBackgroundRefresh(
                    withPreferredDate: Self.preferredBackgroundRefreshDate,
                    userInfo: Self.backgroundRefreshBackgroundTaskIdentifier as NSString
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
    
    #if canImport(BackgroundTasks) && !os(macOS)
    public nonisolated func scheduleDataCleansingBackgroundTask() async throws {
        let request = BGProcessingTaskRequest(identifier: Self.dataCleansingBackgroundTaskIdentifier)
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false

        try BGTaskScheduler.shared.submit(request)
    }
    #endif

    nonisolated func backgroundRefresh() async throws {
        let logger = Logger(subsystem: Bundle.module.bundleIdentifier!, category: "background-refresh")
        
        logger.info("Start background refresh")
        defer {
            logger.info("Background refresh finished")
        }

        do {
            let context = self.persistentContainer.newBackgroundContext()
            context.undoManager = nil

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
                        let updateResults = try await self.updateAccount(accountObjectID, context: context)
                        
                        guard
                            updateResults.previousUserDetailObjectID != updateResults.latestUserDetailObjectID
                        else {
                            return
                        }
                        
                        let notificationContent: UNMutableNotificationContent = await context.perform(schedule: .enqueued) {
                            let account = context.object(with: accountObjectID) as? Account
                            
                            let previousUserDetail = updateResults.previousUserDetailObjectID.flatMap { context.object(with: $0) as? UserDetail }
                            let latestUserDetail = context.object(with: updateResults.latestUserDetailObjectID) as? UserDetail

                            let followingUserChanges = latestUserDetail?.followingUserChanges(from: previousUserDetail)
                            let followerUserChanges = latestUserDetail?.followerUserChanges(from: previousUserDetail)

                            let displayUsername = latestUserDetail?.displayUsername ?? (account?.id).flatMap { $0.twnk_formatted() } ?? accountObjectID.uriRepresentation().absoluteString

                            let notificationContent = UNMutableNotificationContent()
                            notificationContent.threadIdentifier = accountObjectID.uriRepresentation().absoluteString
                            notificationContent.title = displayUsername
                            
                            var changes: [String] = []
                            if let newFollowingUsersCount = followingUserChanges?.followingUsersCount, newFollowingUsersCount > 0 {
                                changes.append(String(localized: "\(newFollowingUsersCount, specifier: "%ld") new following(s)", bundle: .module, comment: "background-refresh notification body."))
                            }
                            if let newUnfollowingUsersCount = followingUserChanges?.unfollowingUsersCount, newUnfollowingUsersCount > 0 {
                                changes.append(String(localized: "\(newUnfollowingUsersCount, specifier: "%ld") new unfollowing(s)", bundle: .module, comment: "background-refresh notification body."))
                            }
                            if let newFollowerUsersCount = followerUserChanges?.followerUsersCount, newFollowerUsersCount > 0 {
                                changes.append(String(localized: "\(newFollowerUsersCount, specifier: "%ld") new follower(s)", bundle: .module, comment: "background-refresh notification body."))
                            }
                            if let newUnfollowerUsersCount = followerUserChanges?.unfollowerUsersCount, newUnfollowerUsersCount > 0 {
                                changes.append(String(localized: "\(newUnfollowerUsersCount, specifier: "%ld") new unfollower(s)", bundle: .module, comment: "background-refresh notification body."))
                            }
                            
                            if changes.isEmpty == false {
                                notificationContent.subtitle = String(localized: "New Data Available", bundle: .module, comment: "background-refresh notification.")
                                notificationContent.body = changes.formatted(.list(type: .and, width: .narrow))
                            } else {
                                notificationContent.body = String(localized: "New Data Available", bundle: .module, comment: "background-refresh notification.")
                            }

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

                try await taskGroup.waitForAll()
            }
        } catch {
            logger.error("Error occurred while update accounts: \(String(describing: error))")

            switch error {
            case is CancellationError, URLError.cancelled:
                break
            default:
                let notificationContent = UNMutableNotificationContent()
                notificationContent.title = String(localized: "Background Refresh", bundle: .module, comment: "background-refresh notification title.")
                notificationContent.subtitle = String(localized: "Error", bundle: .module, comment: "background-refresh notification subtitle.")
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
    nonisolated func handleBackgroundRefreshBackgroundTask(_ backgroundTask: BGTask) {
        let logger = Logger(subsystem: Bundle.module.bundleIdentifier!, category: "background-refresh")
        
        Task { [self] in
            do {
                try await scheduleBackgroundRefreshTask()
            } catch {
                logger.error("Error occurred while schedule background refresh: \(error as NSError, privacy: .public)")
            }
        }
        
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
    
    nonisolated func handleDataCleansingBackgroundTask(_ backgroundTask: BGTask) {
        let logger = Logger(subsystem: Bundle.module.bundleIdentifier!, category: "data-cleansing")
        
        Task { [self] in
            do {
                try await scheduleDataCleansingBackgroundTask()
            } catch {
                logger.error("Error occurred while schedule data cleansing: \(error as NSError, privacy: .public)")
            }
        }
        
        let task = Task { [self] in
            do {
                try await cleansingAllData()
                
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
    @discardableResult
    public nonisolated func handleBackgroundRefreshBackgroundTask(_ backgroundTasks: Set<WKRefreshBackgroundTask>) -> Set<WKRefreshBackgroundTask> {
        guard let backgroundTask = backgroundTasks.first(where: { $0.userInfo as? NSString == Self.backgroundRefreshBackgroundTaskIdentifier as NSString }) else {
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
