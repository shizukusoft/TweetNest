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

    private let logger = Logger(subsystem: Bundle.tweetNestKit.bundleIdentifier!, category: String(reflecting: BackgroundTaskScheduler.self))

    private init() { }
}

extension BackgroundTaskScheduler {
    public nonisolated func scheduleBackgroundTasks() async {
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

                let backgroundDataCleansingRequest = BGProcessingTaskRequest(identifier: Self.dataCleansingBackgroundTaskIdentifier)
                backgroundDataCleansingRequest.requiresNetworkConnectivity = false
                backgroundDataCleansingRequest.requiresExternalPower = true
                backgroundDataCleansingRequest.earliestBeginDate = Self.preferredBackgroundDataCleansingDate

                try BGTaskScheduler.shared.submit(backgroundRefreshRequest)
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
    public nonisolated func cancelBackgroundTasks() {
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: Self.backgroundRefreshBackgroundTaskIdentifier)
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: Self.dataCleansingBackgroundTaskIdentifier)
    }
    #endif
}

extension BackgroundTaskScheduler {
    @discardableResult
    private func backgroundRefresh() async throws -> Bool {
        guard TweetNestKitUserDefaults.standard.isBackgroundUpdateEnabled else { return false }

        logger.notice("Start background refresh")
        defer {
            logger.notice("Background refresh finished with cancelled: \(Task.isCancelled)")
        }

        await self.scheduleBackgroundTasks()

        do {
            return try await session.fetchNewData()
        } catch {
            logger.error("Error occurred while background refresh: \(error as NSError, privacy: .public)")
            throw error
        }
    }

    private func backgroundDataCleansing() async throws {
        guard TweetNestKitUserDefaults.standard.isBackgroundUpdateEnabled else { return }

        logger.notice("Start background data cleansing")
        defer {
            logger.notice("Background data cleansing finished with cancelled: \(Task.isCancelled)")
        }

        await self.scheduleBackgroundTasks()

        do {
            try await session.cleansingAllData()
        } catch {
            logger.error("Error occurred while background data cleansing: \(error as NSError, privacy: .public)")
            throw error
        }
    }
}

#if canImport(BackgroundTasks) && !os(macOS)
extension BackgroundTaskScheduler {
    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    @discardableResult
    public nonisolated func registerBackgroundTasks() -> Bool {
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

    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    nonisolated func handleBackgroundRefreshBackgroundTask(_ backgroundTask: BGTask) {
        let task = Task {
            do {
                let hasChanges = try await self.backgroundRefresh()

                if hasChanges {
                    await MainActor.run {
                        UIApplication.shared.connectedScenes.forEach {
                            UIApplication.shared.requestSceneSessionRefresh($0.session)
                        }
                    }
                }

                backgroundTask.setTaskCompleted(success: true)
            } catch {
                backgroundTask.setTaskCompleted(success: false)
            }
        }

        backgroundTask.expirationHandler = { [logger] in
            logger.notice("Background refresh task expired for: \(backgroundTask.identifier, privacy: .public)")
            task.cancel()
            task.waitUntilFinished()
        }
    }

    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    nonisolated func handleDataCleansingBackgroundTask(_ backgroundTask: BGTask) {
        let task = Task {
            do {
                try await self.backgroundDataCleansing()

                await MainActor.run {
                    UIApplication.shared.connectedScenes.forEach {
                        UIApplication.shared.requestSceneSessionRefresh($0.session)
                    }
                }

                backgroundTask.setTaskCompleted(success: true)
            } catch {
                backgroundTask.setTaskCompleted(success: false)
            }
        }

        backgroundTask.expirationHandler = { [logger] in
            logger.notice("Background refresh task expired for: \(backgroundTask.identifier, privacy: .public)")
            task.cancel()
            task.waitUntilFinished()
        }
    }
}
#elseif canImport(WatchKit)
extension BackgroundTaskScheduler {
    @discardableResult
    public nonisolated func handleBackgroundRefreshBackgroundTask(_ backgroundTasks: Set<WKRefreshBackgroundTask>) -> Set<WKRefreshBackgroundTask> {
        guard
            let backgroundTask = backgroundTasks.first(where: { $0.userInfo as? NSString == Self.backgroundRefreshBackgroundTaskIdentifier as NSString })
        else {
            return []
        }

        let task = Task {
            backgroundTask.setTaskCompletedWithSnapshot((try? await self.backgroundRefresh()) ?? false)
        }

        backgroundTask.expirationHandler = { [logger] in
            logger.notice("Background refresh task expired for: \(String(describing: backgroundTask.userInfo), privacy: .public)")
            task.cancel()
            task.waitUntilFinished()
        }

        return [backgroundTask]
    }
}
#endif

#endif
