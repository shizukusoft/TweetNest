//
//  BackgroundTaskScheduler.swift
//  BackgroundTaskScheduler
//
//  Created by Jaehong Kang on 2021/09/08.
//

import Foundation
import UserNotifications
import UnifiedLogging
#if canImport(BackgroundTasks) && !os(macOS)
import BackgroundTasks
#endif
#if canImport(WatchKit)
import WatchKit
#endif

public actor BackgroundTaskScheduler {
    public enum ApplicationPhase: Hashable, Equatable {
        case background
        case inactive
        case active
    }

    public static let shared = BackgroundTaskScheduler()

    public static let backgroundRefreshBackgroundTaskIdentifier: String = "\(Bundle.tweetNestKit.bundleIdentifier!).background-refresh"
    public static let dataCleansingBackgroundTaskIdentifier: String = "\(Bundle.tweetNestKit.bundleIdentifier!).data-cleansing"

    static var preferredBackgroundTasksTimeInterval: TimeInterval {
        (15 / 2) * 60 // Fetch no earlier than 7.5 minutes from now
    }

    static var preferredBackgroundRefreshDate: Date {
        Date(timeIntervalSinceNow: preferredBackgroundTasksTimeInterval)
    }

    private var backgroundTimer: DispatchSourceTimer? {
        willSet {
            guard backgroundTimer !== newValue else { return }

            backgroundTimer?.cancel()
        }
        didSet {
            guard backgroundTimer !== oldValue else { return }

            backgroundTimer?.activate()
        }
    }

    private var isRunning: Bool = false

    private init() { }

    func newBackgroundTimer() -> DispatchSourceTimer {
        let backgroundTimer = DispatchSource.makeTimerSource()
        backgroundTimer.setEventHandler {
            Task.detached(priority: .utility) {
                await self.backgroundRefresh(dataCleansing: true)
            }
        }
        backgroundTimer.schedule(deadline: .now() + Self.preferredBackgroundTasksTimeInterval)

        return backgroundTimer
    }
}

extension BackgroundTaskScheduler {
    public func scheduleBackgroundTasks(for applicationPhase: ApplicationPhase) async throws {
        guard UserDefaults.tweetNestKit[Session.backgroundUpdateUserDefaultsKey] != false else { return }

        switch applicationPhase {
        case .active, .inactive:
            self.backgroundTimer = newBackgroundTimer()
        case .background:
            #if (canImport(BackgroundTasks) && !os(macOS)) || canImport(WatchKit)
            self.backgroundTimer = nil

            #if canImport(BackgroundTasks) && !os(macOS)
            let backgroundRefreshRequest = BGAppRefreshTaskRequest(identifier: Self.backgroundRefreshBackgroundTaskIdentifier)
            backgroundRefreshRequest.earliestBeginDate = Self.preferredBackgroundRefreshDate

            try BGTaskScheduler.shared.submit(backgroundRefreshRequest)

            let lastCleanseDate = await Session.shared.preferences.lastCleansed

            let now = Date()
            let twoDay = TimeInterval(2 * 24 * 60 * 60)

            // Clean the database at most once per two day.
            guard now > (lastCleanseDate + twoDay) else { return }

            let backgroundDataCleansingRequest = BGProcessingTaskRequest(identifier: Self.dataCleansingBackgroundTaskIdentifier)
            backgroundDataCleansingRequest.requiresNetworkConnectivity = true
            backgroundDataCleansingRequest.requiresExternalPower = false

            try BGTaskScheduler.shared.submit(backgroundDataCleansingRequest)
            #endif

            #if canImport(WatchKit)
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

            #else
            self.backgroundTimer = newBackgroundTimer()
            #endif
        }
    }
}

extension BackgroundTaskScheduler {
    @discardableResult
    func backgroundRefresh(dataCleansing: Bool = false) async -> Bool {
        guard UserDefaults.tweetNestKit[Session.backgroundUpdateUserDefaultsKey] != false else { return true }
        let logger = Logger(subsystem: Bundle.tweetNestKit.bundleIdentifier!, category: "background-refresh")

        do {
            try await scheduleBackgroundTasks(for: .background)
        } catch {
            logger.error("Error occurred while schedule background tasks: \(error as NSError, privacy: .public)")
        }

        guard isRunning == false else { return true }

        isRunning = true
        defer {
            isRunning = false
        }

        return await withExtendedBackgroundExecution {
            logger.notice("Start background refresh")
            defer {
                logger.notice("Background refresh finished with cancelled: \(Task.isCancelled)")
            }

            do {
                try await Session.shared.updateAllAccounts()
                if dataCleansing {
                    try await Session.shared.cleansingAllData()
                }

                return true
            } catch {
                logger.error("Error occurred while update accounts: \(String(describing: error))")

                switch error {
                case is CancellationError, URLError.cancelled:
                    break
                default:
                    let notificationContent = UNMutableNotificationContent()
                    notificationContent.title = String(localized: "Background Refresh", bundle: .tweetNestKit, comment: "background-refresh notification title.")
                    notificationContent.subtitle = String(localized: "Error", bundle: .tweetNestKit, comment: "background-refresh notification subtitle.")
                    notificationContent.body = error.localizedDescription
                    notificationContent.sound = .default

                    let notificationRequest = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: nil)

                    do {
                        try await UNUserNotificationCenter.current().add(notificationRequest)
                    } catch {
                        logger.error("Error occurred while request notification: \(String(reflecting: error), privacy: .public)")
                    }
                }

                return false
            }
        }
    }

    @discardableResult
    func backgroundDataCleansing() async -> Bool {
        guard UserDefaults.tweetNestKit[Session.backgroundUpdateUserDefaultsKey] != false else { return true }
        let logger = Logger(subsystem: Bundle.tweetNestKit.bundleIdentifier!, category: "background-data-cleansing")

        do {
            try await scheduleBackgroundTasks(for: .background)
        } catch {
            logger.error("Error occurred while schedule background tasks: \(error as NSError, privacy: .public)")
        }

        guard isRunning == false else { return true }

        isRunning = true
        defer {
            isRunning = false
        }

        return await withExtendedBackgroundExecution {
            logger.notice("Start background data cleansing")
            defer {
                logger.notice("Background data cleansing finished with cancelled: \(Task.isCancelled)")
            }

            do {
                try await Session.shared.cleansingAllData()

                return true
            } catch {
                logger.error("Error occurred while data cleansing: \(String(describing: error))")

                switch error {
                case is CancellationError, URLError.cancelled:
                    break
                default:
                    let notificationContent = UNMutableNotificationContent()
                    notificationContent.title = String(localized: "Background Refresh", bundle: .tweetNestKit, comment: "background-refresh notification title.")
                    notificationContent.subtitle = String(localized: "Error", bundle: .tweetNestKit, comment: "background-refresh notification subtitle.")
                    notificationContent.body = error.localizedDescription
                    notificationContent.sound = .default

                    let notificationRequest = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: nil)

                    do {
                        try await UNUserNotificationCenter.current().add(notificationRequest)
                    } catch {
                        logger.error("Error occurred while request notification: \(String(reflecting: error), privacy: .public)")
                    }
                }

                return false
            }
        }
    }
}
