//
//  BackgroundTaskScheduler+BackgroundTask.swift
//  BackgroundTaskScheduler+BackgroundTask
//
//  Created by Jaehong Kang on 2021/09/08.
//

#if canImport(BackgroundTasks) && !os(macOS)
import Foundation
import BackgroundTasks
import UnifiedLogging

extension BackgroundTaskScheduler {
    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    @discardableResult
    public nonisolated func registerBackgroundTasks() -> Bool {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.backgroundRefreshBackgroundTaskIdentifier, using: nil, launchHandler: handleBackgroundRefreshBackgroundTask(_:)) &&
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.dataCleansingBackgroundTaskIdentifier, using: nil, launchHandler: handleDataCleansingBackgroundTask(_:))
    }

    nonisolated func handleBackgroundRefreshBackgroundTask(_ backgroundTask: BGTask) {
        ExpiringTask.detached { expire in
            let logger = Logger(subsystem: Bundle.tweetNestKit.bundleIdentifier!, category: "background-refresh")

            backgroundTask.expirationHandler = {
                logger.notice("Background task expired for: \(backgroundTask.identifier, privacy: .public)")
                expire()
            }

            backgroundTask.setTaskCompleted(success: await self.backgroundRefresh())
        }
    }

    nonisolated func handleDataCleansingBackgroundTask(_ backgroundTask: BGTask) {
        ExpiringTask.detached { expire in
            let logger = Logger(subsystem: Bundle.tweetNestKit.bundleIdentifier!, category: "data-cleansing")

            backgroundTask.expirationHandler = {
                logger.notice("Background task expired for: \(backgroundTask.identifier, privacy: .public)")
                expire()
            }

            backgroundTask.setTaskCompleted(success: await self.backgroundDataCleansing())
        }
    }
}
#endif
