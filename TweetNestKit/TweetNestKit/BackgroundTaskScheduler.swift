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
    public static let waitingCloudKitSyncHelperBackgroundTaskIdentifier: String = "\(Bundle.tweetNestKit.bundleIdentifier!).waiting-cloudkit-sync"

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
                try BGTaskScheduler.shared.submit(backgroundRefreshRequest)

                let backgroundDataCleansingRequest = BGProcessingTaskRequest(identifier: Self.dataCleansingBackgroundTaskIdentifier)
                backgroundDataCleansingRequest.requiresNetworkConnectivity = false
                backgroundDataCleansingRequest.requiresExternalPower = true
                backgroundDataCleansingRequest.earliestBeginDate = Self.preferredBackgroundDataCleansingDate
                try BGTaskScheduler.shared.submit(backgroundDataCleansingRequest)

                let backgroundWaitingCloudKitSyncRequest = BGProcessingTaskRequest(identifier: Self.waitingCloudKitSyncHelperBackgroundTaskIdentifier)
                backgroundWaitingCloudKitSyncRequest.requiresNetworkConnectivity = true
                backgroundWaitingCloudKitSyncRequest.requiresExternalPower = false
                backgroundWaitingCloudKitSyncRequest.earliestBeginDate = nil
                try BGTaskScheduler.shared.submit(backgroundWaitingCloudKitSyncRequest)
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

        do {
            return try await session.fetchNewData()
        } catch {
            logger.error("Error occurred while background refresh: \(error as NSError, privacy: .public)")
            throw error
        }
    }

    @available(watchOS, unavailable)
    private func backgroundDataCleansing() async throws {
        guard TweetNestKitUserDefaults.standard.isBackgroundUpdateEnabled else { return }

        do {
            try await session.cleansingAllData()
        } catch {
            logger.error("Error occurred while background data cleansing: \(error as NSError, privacy: .public)")
            throw error
        }
    }

    @discardableResult
    private func waitCloudKitSync(shouldRetry: Bool = true) async -> Bool {
        for await cloudKitEvents in session.persistentContainer.$cloudKitEvents.values {
            guard !Task.isCancelled else {
                break
            }

            guard cloudKitEvents.allSatisfy({ $0.value.endDate != nil }) else {
                continue
            }

            guard shouldRetry else {
                try? await Task.sleep(nanoseconds: 60 * 1_000_000_000) // 1 mins.
                break
            }

            return await waitCloudKitSync(shouldRetry: false)
        }

        return await session.persistentContainer.cloudKitEvents.lazy
            .filter { $0.value.succeeded }
            .contains { $0.value.type == .import }
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
            ),
            BGTaskScheduler.shared.register(
                forTaskWithIdentifier: Self.waitingCloudKitSyncHelperBackgroundTaskIdentifier,
                using: nil,
                launchHandler: handleWaitingCloudKitSyncBackgroundTask(_:)
            )
        ]
        .allSatisfy { $0 }
    }

    private nonisolated func handleBackgroundTask(_ backgroundTask: BGTask, _ action: @escaping () async throws -> Void) {
        let task = Task {
            do {
                logger.notice("Start background task for \(backgroundTask.identifier, privacy: .public)")
                defer {
                    logger.notice("Background task finished for \(backgroundTask.identifier, privacy: .public) with cancelled: \(Task.isCancelled)")
                }

                await self.scheduleBackgroundTasks()

                try await action()

                backgroundTask.setTaskCompleted(success: true)
            } catch {
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
    nonisolated func handleBackgroundRefreshBackgroundTask(_ backgroundTask: BGTask) {
        handleBackgroundTask(backgroundTask) {
            let hasChanges = try await self.backgroundRefresh()

            if hasChanges {
                await self.requestScenesRefresh()
            }
        }
    }

    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    nonisolated func handleDataCleansingBackgroundTask(_ backgroundTask: BGTask) {
        handleBackgroundTask(backgroundTask) {
            try await self.backgroundDataCleansing()

            await self.requestScenesRefresh()
        }
    }

    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    nonisolated func handleWaitingCloudKitSyncBackgroundTask(_ backgroundTask: BGTask) {
        handleBackgroundTask(backgroundTask) {
            let hasChanges = await self.waitCloudKitSync()

            if hasChanges {
                await self.requestScenesRefresh()
            }
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
    public nonisolated func handleBackgroundRefreshBackgroundTask(_ backgroundTasks: Set<WKRefreshBackgroundTask>) -> Set<WKRefreshBackgroundTask> {
        guard
            let backgroundTask = backgroundTasks.first(where: { $0.userInfo as? NSString == Self.backgroundRefreshBackgroundTaskIdentifier as NSString })
        else {
            return []
        }

        let task = Task {
            do {
                let hasChanges = try await withThrowingTaskGroup(of: Bool.self) { taskGroup in
                    taskGroup.addTask {
                        try await self.backgroundRefresh()
                    }
                    taskGroup.addTask {
                        await self.waitCloudKitSync()
                    }

                    return try await taskGroup.reduce(into: false) { partialResult, taskResult in
                        partialResult = partialResult || taskResult
                    }
                }

                backgroundTask.setTaskCompletedWithSnapshot(hasChanges)
            } catch {
                backgroundTask.setTaskCompletedWithSnapshot(false)
            }
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
