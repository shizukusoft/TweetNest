//
//  BackgroundTaskScheduler.swift
//  BackgroundTaskScheduler
//
//  Created by Jaehong Kang on 2021/09/08.
//

#if (canImport(BackgroundTasks) && !os(macOS)) || canImport(WatchKit)

import Foundation
import UserNotifications
import UnifiedLogging
import BackgroundTask
#if canImport(BackgroundTasks) && !os(macOS)
import BackgroundTasks
#endif
#if canImport(WatchKit)
import WatchKit
#endif

public actor BackgroundTaskScheduler {
    public static let shared = BackgroundTaskScheduler()

    public static let backgroundRefreshBackgroundTaskIdentifier: String = "\(Bundle.tweetNestKit.bundleIdentifier!).background-refresh"
    public static let dataCleansingBackgroundTaskIdentifier: String = "\(Bundle.tweetNestKit.bundleIdentifier!).data-cleansing"

    private static var preferredBackgroundRefreshDate: Date {
        TweetNestKitUserDefaults.standard.lastFetchNewDataDate.addingTimeInterval(TweetNestKitUserDefaults.standard.fetchNewDataInterval)
    }

    private static var preferredBackgroundDataCleansingDate: Date {
        TweetNestKitUserDefaults.standard.lastCleansedDate.addingTimeInterval(Session.cleansingDataInterval)
    }

    private var session: Session {
        .shared
    }

    private lazy var logger = Logger(subsystem: Bundle.tweetNestKit.bundleIdentifier!, category: String(reflecting: Self.self))

    private init() { }
}

extension BackgroundTaskScheduler {
    @MainActor
    public func scheduleBackgroundTasks() {
        guard TweetNestKitUserDefaults.standard.isBackgroundUpdateEnabled else { return }

        #if canImport(BackgroundTasks) && !os(macOS)
        do {
            let backgroundRefreshRequest = BGAppRefreshTaskRequest(identifier: Self.backgroundRefreshBackgroundTaskIdentifier)
            backgroundRefreshRequest.earliestBeginDate = Self.preferredBackgroundRefreshDate

            try BGTaskScheduler.shared.submit(backgroundRefreshRequest)

            let backgroundDataCleansingRequest = BGProcessingTaskRequest(identifier: Self.dataCleansingBackgroundTaskIdentifier)
            backgroundDataCleansingRequest.requiresNetworkConnectivity = true
            backgroundDataCleansingRequest.requiresExternalPower = false
            backgroundDataCleansingRequest.earliestBeginDate = Self.preferredBackgroundDataCleansingDate

            try BGTaskScheduler.shared.submit(backgroundDataCleansingRequest)
        } catch {
            Task(priority: .high) {
                await self.logger.error("Error occurred while schedule background tasks: \(error as NSError, privacy: .public)")
            }
        }
        #elseif canImport(WatchKit)
        WKExtension.shared().scheduleBackgroundRefresh(
            withPreferredDate: Self.preferredBackgroundRefreshDate,
            userInfo: Self.backgroundRefreshBackgroundTaskIdentifier as NSString
        ) { error in
            if let error = error {
                Task(priority: .high) {
                    await self.logger.error("Error occurred while schedule background tasks: \(error as NSError, privacy: .public)")
                }
            }
        }
        #endif
    }

    public nonisolated func cancelBackgroundTasks() {
        #if canImport(BackgroundTasks) && !os(macOS)
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: Self.backgroundRefreshBackgroundTaskIdentifier)
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: Self.dataCleansingBackgroundTaskIdentifier)
        #endif
    }
}

extension BackgroundTaskScheduler {
    @discardableResult
    private func backgroundRefresh() async -> Bool {
        guard TweetNestKitUserDefaults.standard.isBackgroundUpdateEnabled else { return false }

        logger.notice("Start background refresh")
        defer {
            logger.notice("Background refresh finished with cancelled: \(Task.isCancelled)")
        }

        Task.detached {
            await self.scheduleBackgroundTasks()
        }

        do {
            try await session.fetchNewData(cleansingData: false)
            return true
        } catch {
            logger.error("Error occurred while background refresh: \(error as NSError, privacy: .public)")
            return false
        }
    }

    @discardableResult
    private func backgroundDataCleansing() async -> Bool {
        guard TweetNestKitUserDefaults.standard.isBackgroundUpdateEnabled else { return false }

        logger.notice("Start background data cleansing")
        defer {
            logger.notice("Background data cleansing finished with cancelled: \(Task.isCancelled)")
        }

        Task.detached {
            await self.scheduleBackgroundTasks()
        }

        do {
            try await session.cleansingAllData()
            return true
        } catch {
            logger.error("Error occurred while background data cleansing: \(error as NSError, privacy: .public)")
            return false
        }
    }
}

#endif

#if canImport(BackgroundTasks) && !os(macOS)
extension BackgroundTaskScheduler {
    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    @discardableResult
    public nonisolated func registerBackgroundTasks() -> Bool {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.backgroundRefreshBackgroundTaskIdentifier, using: nil, launchHandler: handleBackgroundRefreshBackgroundTask(_:)) &&
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.dataCleansingBackgroundTaskIdentifier, using: nil, launchHandler: handleDataCleansingBackgroundTask(_:))
    }

    nonisolated func handleBackgroundRefreshBackgroundTask(_ backgroundTask: BGTask) {
        Task.expiring { expire in
            let logger = await self.logger

            backgroundTask.expirationHandler = {
                logger.notice("Background refresh task expired for: \(backgroundTask.identifier, privacy: .public)")
                expire()
            }

            backgroundTask.setTaskCompleted(success: await self.backgroundRefresh())
        }
    }

    nonisolated func handleDataCleansingBackgroundTask(_ backgroundTask: BGTask) {
        Task.expiring { expire in
            let logger = await self.logger

            backgroundTask.expirationHandler = {
                logger.notice("Background data cleansing task expired for: \(backgroundTask.identifier, privacy: .public)")
                expire()
            }

            backgroundTask.setTaskCompleted(success: await self.backgroundDataCleansing())
        }
    }
}
#elseif canImport(WatchKit)
extension BackgroundTaskScheduler {
    @discardableResult
    public nonisolated func handleBackgroundRefreshBackgroundTask(_ backgroundTasks: Set<WKRefreshBackgroundTask>) -> Set<WKRefreshBackgroundTask> {
        guard let backgroundTask = backgroundTasks.first(where: { $0.userInfo as? NSString == Self.backgroundRefreshBackgroundTaskIdentifier as NSString }) else {
            return []
        }

        Task.expiring { expire in
            let logger = await self.logger

            backgroundTask.expirationHandler = {
                logger.notice("Background refresh task expired for: \(String(describing: backgroundTask.userInfo), privacy: .public)")
                expire()
            }

            backgroundTask.setTaskCompletedWithSnapshot(await self.backgroundRefresh())
        }

        return [backgroundTask]
    }
}
#endif
