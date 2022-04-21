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

@MainActor
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

    private init() { }
}

extension BackgroundTaskScheduler {
    public func scheduleBackgroundTasks() async throws {
        guard TweetNestKitUserDefaults.standard.isBackgroundUpdateEnabled else { return }

        #if canImport(BackgroundTasks) && !os(macOS)
        let backgroundRefreshRequest = BGAppRefreshTaskRequest(identifier: Self.backgroundRefreshBackgroundTaskIdentifier)
        backgroundRefreshRequest.earliestBeginDate = Self.preferredBackgroundRefreshDate

        try BGTaskScheduler.shared.submit(backgroundRefreshRequest)

        let backgroundDataCleansingRequest = BGProcessingTaskRequest(identifier: Self.dataCleansingBackgroundTaskIdentifier)
        backgroundDataCleansingRequest.requiresNetworkConnectivity = true
        backgroundDataCleansingRequest.requiresExternalPower = false
        backgroundDataCleansingRequest.earliestBeginDate = Self.preferredBackgroundDataCleansingDate

        try BGTaskScheduler.shared.submit(backgroundDataCleansingRequest)
        #elseif canImport(WatchKit)
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
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
        #endif
    }

    public func cancelBackgroundTasks() {
        #if canImport(BackgroundTasks) && !os(macOS)
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: Self.backgroundRefreshBackgroundTaskIdentifier)
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: Self.dataCleansingBackgroundTaskIdentifier)
        #endif
    }
}

extension BackgroundTaskScheduler {
    @discardableResult
    func backgroundRefresh() async -> Bool {
        guard TweetNestKitUserDefaults.standard.isBackgroundUpdateEnabled else { return false }

        let logger = Logger(subsystem: Bundle.tweetNestKit.bundleIdentifier!, category: "background-refresh")

        do {
            try await scheduleBackgroundTasks()
        } catch {
            logger.error("Error occurred while schedule background tasks: \(error as NSError, privacy: .public)")
        }

        logger.notice("Start background refresh")
        defer {
            logger.notice("Background refresh finished with cancelled: \(Task.isCancelled)")
        }

        do {
            return try await session.fetchNewData(cleansingData: false)
        } catch {
            logger.error("Error occurred while update accounts: \(String(describing: error))")
            return false
        }
    }

    @discardableResult
    func backgroundDataCleansing() async -> Bool {
        guard TweetNestKitUserDefaults.standard.isBackgroundUpdateEnabled else { return false }

        let logger = Logger(subsystem: Bundle.tweetNestKit.bundleIdentifier!, category: "background-data-cleansing")

        do {
            try await scheduleBackgroundTasks()
        } catch {
            logger.error("Error occurred while schedule background tasks: \(error as NSError, privacy: .public)")
        }

        logger.notice("Start background data cleansing")
        defer {
            logger.notice("Background data cleansing finished with cancelled: \(Task.isCancelled)")
        }

        do {
            try await session.cleansingAllData()

            return true
        } catch {
            logger.error("Error occurred while data cleansing: \(String(describing: error))")
            return false
        }
    }
}

#endif
