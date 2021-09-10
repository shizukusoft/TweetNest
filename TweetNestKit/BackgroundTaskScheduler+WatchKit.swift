//
//  BackgroundTaskScheduler+WatchKit.swift
//  BackgroundTaskScheduler+WatchKit
//
//  Created by Jaehong Kang on 2021/09/08.
//

#if canImport(WatchKit)
import Foundation
import WatchKit
import UnifiedLogging

extension BackgroundTaskScheduler {
    @discardableResult
    public nonisolated func handleBackgroundRefreshBackgroundTask(_ backgroundTasks: Set<WKRefreshBackgroundTask>) -> Set<WKRefreshBackgroundTask> {
        guard let backgroundTask = backgroundTasks.first(where: { $0.userInfo as? NSString == Self.backgroundRefreshBackgroundTaskIdentifier as NSString }) else {
            return []
        }

        Task.detached { [self] in
            await withTaskExpirationHandler { expirationHandler in
                let logger = Logger(subsystem: Bundle.tweetNestKit.bundleIdentifier!, category: "background-refresh")

                backgroundTask.expirationHandler = {
                    logger.notice("Background task expired for: \(String(describing: backgroundTask.userInfo), privacy: .public)")
                    expirationHandler()
                }

                backgroundTask.setTaskCompletedWithSnapshot(await backgroundRefresh())
            }
        }

        return [backgroundTask]
    }
}
#endif
