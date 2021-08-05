//
//  TweetNestAppDelegate.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/03/22.
//

import UIKit
import BackgroundTasks
import UnifiedLogging
import TweetNestKit

extension TweetNestAppDelegate {
    func appRefresh(backgroundTask: BGTask) {
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "refresh")

        let task = Task.detached {
            logger.info("Start background task for: \(backgroundTask.identifier)")
            defer {
                logger.info("Background task finished for: \(backgroundTask.identifier)")
            }

            do {
                try await Session.shared.appRefresh()
                backgroundTask.setTaskCompleted(success: true)
            } catch {
                backgroundTask.setTaskCompleted(success: false)
            }
        }

        backgroundTask.expirationHandler = {
            logger.info("Background task expired for: \(backgroundTask.identifier)")
            task.cancel()
        }
    }
}

extension TweetNestAppDelegate: UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Session.refreshBackgroundTaskIdentifier, using: nil, launchHandler: appRefresh(backgroundTask:))
        return true
    }
}
