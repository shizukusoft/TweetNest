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
#if canImport(UIKit)
import UIKit
#endif
#if canImport(WatchKit)
import WatchKit
#endif

public class BackgroundTaskScheduler {
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

    private let logger = Logger(subsystem: Bundle.tweetNestKit.bundleIdentifier!, category: String(reflecting: BackgroundTaskScheduler.self))

    private init() { }
}

extension BackgroundTaskScheduler {
    public func scheduleBackgroundTasks() async {
        do {
            try await withExtendedBackgroundExecution(priority: .high) {
                guard TweetNestKitUserDefaults.standard.isBackgroundUpdateEnabled else {
                    #if canImport(BackgroundTasks) && !os(macOS)
                    BackgroundTaskScheduler.shared.cancelBackgroundTasks()
                    #endif
                    return
                }

                #if canImport(BackgroundTasks) && !os(macOS)
                let backgroundRefreshRequest = BGAppRefreshTaskRequest(identifier: Self.backgroundRefreshBackgroundTaskIdentifier)
                backgroundRefreshRequest.earliestBeginDate = Self.preferredBackgroundRefreshDate
                try BGTaskScheduler.shared.submit(backgroundRefreshRequest)

                let backgroundDataCleansingRequest = BGProcessingTaskRequest(identifier: Self.dataCleansingBackgroundTaskIdentifier)
                backgroundDataCleansingRequest.requiresNetworkConnectivity = false
                backgroundDataCleansingRequest.requiresExternalPower = true
                backgroundDataCleansingRequest.earliestBeginDate = Self.preferredBackgroundDataCleansingDate
                try BGTaskScheduler.shared.submit(backgroundDataCleansingRequest)
                #elseif canImport(WatchKit)
                try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                    DispatchQueue.main.async {
                        WKExtension.shared().scheduleBackgroundRefresh(
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
        } catch {
            logger.error("Error occurred while schedule background tasks: \(error as NSError, privacy: .public)")
        }
    }

    #if canImport(BackgroundTasks) && !os(macOS)
    public func cancelBackgroundTasks() {
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: Self.backgroundRefreshBackgroundTaskIdentifier)
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: Self.dataCleansingBackgroundTaskIdentifier)
    }
    #endif
}

extension BackgroundTaskScheduler {
    @discardableResult
    private func backgroundRefresh() async throws -> Bool {
        guard TweetNestKitUserDefaults.standard.isBackgroundUpdateEnabled else { return false }

        return try await session.fetchNewData()
    }

    @available(watchOS, unavailable)
    private func backgroundDataCleansing() async throws {
        guard TweetNestKitUserDefaults.standard.isBackgroundUpdateEnabled else { return }

        try await session.cleansingAllData()
    }
}

#if canImport(BackgroundTasks) && !os(macOS)
extension BackgroundTaskScheduler {
    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    @discardableResult
    public func registerBackgroundTasks() -> Bool {
        [
            BGTaskScheduler.shared.register(
                forTaskWithIdentifier: Self.backgroundRefreshBackgroundTaskIdentifier,
                using: nil,
                launchHandler: handleBackgroundRefreshBackgroundTask(_:)
            ),
            BGTaskScheduler.shared.register(
                forTaskWithIdentifier: Self.dataCleansingBackgroundTaskIdentifier,
                using: nil,
                launchHandler: handleDataCleansingBackgroundTask(_:)
            )
        ]
        .allSatisfy { $0 }
    }

    private func handleBackgroundTask(_ backgroundTask: BGTask, _ action: @escaping @Sendable () async throws -> Void) {
        let task = Task {
            do {
                logger.notice("Start background task for \(backgroundTask.identifier, privacy: .public)")
                defer {
                    logger.log(
                        level: Task.isCancelled ? .warning : .notice,
                        "Background task finished for \(backgroundTask.identifier, privacy: .public) with cancelled: \(Task.isCancelled)"
                    )
                }

                await self.scheduleBackgroundTasks()

                try await action()

                backgroundTask.setTaskCompleted(success: true)
            } catch {
                logger.error("Error occurred while background task for \(backgroundTask.identifier, privacy: .public): \(error as NSError, privacy: .public)")

                backgroundTask.setTaskCompleted(success: false)
            }
        }

        backgroundTask.expirationHandler = { [logger] in
            logger.notice("Background task expired for: \(backgroundTask.identifier, privacy: .public)")
            task.cancel()
            task.waitUntilFinished()
        }
    }

    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    func handleBackgroundRefreshBackgroundTask(_ backgroundTask: BGTask) {
        handleBackgroundTask(backgroundTask) {
            let hasChanges = try await self.backgroundRefresh()

            if hasChanges {
                await self.requestScenesRefresh()
            }
        }
    }

    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    func handleDataCleansingBackgroundTask(_ backgroundTask: BGTask) {
        handleBackgroundTask(backgroundTask) {
            try await self.backgroundDataCleansing()

            await self.requestScenesRefresh()
        }
    }

    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    @MainActor
    private func requestScenesRefresh() {
        for connectedScene in UIApplication.shared.connectedScenes {
            guard connectedScene.activationState == .background else {
                continue
            }

            DispatchQueue.main.async {
                UIApplication.shared.requestSceneSessionRefresh(connectedScene.session)
            }
        }
    }
}
#elseif canImport(WatchKit)
extension BackgroundTaskScheduler {
    @discardableResult
    public func handleBackgroundRefreshBackgroundTask(_ backgroundTasks: Set<WKRefreshBackgroundTask>) -> Set<WKRefreshBackgroundTask> {
        guard
            let backgroundTask = backgroundTasks.first(where: { $0.userInfo as? NSString == Self.backgroundRefreshBackgroundTaskIdentifier as NSString })
        else {
            return []
        }

        let task = Task {
            logger.notice("Start refresh background task with \(String(describing: backgroundTask.userInfo), privacy: .public)")
            defer {
                logger.log(
                    level: Task.isCancelled ? .warning : .notice,
                    "Refresh Background task finished with \(String(describing: backgroundTask.userInfo), privacy: .public) with cancelled: \(Task.isCancelled)"
                )
            }

            do {
                let hasChanges = try await self.backgroundRefresh()

                backgroundTask.setTaskCompletedWithSnapshot(hasChanges)
            } catch {
                logger.error(
                    """
                    Error occurred while refresh background task with \
                    \(String(describing: backgroundTask.userInfo), privacy: .public): \(error as NSError, privacy: .public)
                    """
                )

                backgroundTask.setTaskCompletedWithSnapshot(false)
            }
        }

        backgroundTask.expirationHandler = { [logger] in
            logger.notice("Refresh background task expired for: \(String(describing: backgroundTask.userInfo), privacy: .public)")
            task.cancel()
            task.waitUntilFinished()
        }

        return [backgroundTask]
    }
}
#endif

#endif
