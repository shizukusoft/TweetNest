//
//  TweetNestAppDelegate.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/03/22.
//

import UIKit
import BackgroundTasks
import TweetNestKit

extension TweetNestAppDelegate {
    static let refreshBackgroundTaskIdentifier: String = Bundle.main.bundleIdentifier! + ".refresh"

    func scheduleRefresh() throws {
        let request = BGAppRefreshTaskRequest(identifier: Self.refreshBackgroundTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 5 * 60) // Fetch no earlier than 5 minutes from now

        try BGTaskScheduler.shared.submit(request)
    }

    func refresh(backgroundTask: BGTask) {
        do {
            try scheduleRefresh()
        } catch {
            debugPrint(error)
        }

        let task = Task {
            do {
                try await Session.shared.updateAccounts()

                backgroundTask.setTaskCompleted(success: true)
            } catch {
                backgroundTask.setTaskCompleted(success: false)
            }
        }

        backgroundTask.expirationHandler = {
            task.cancel()
        }
    }
}

extension TweetNestAppDelegate: UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.refreshBackgroundTaskIdentifier, using: nil) { backgroundTask in
            self.refresh(backgroundTask: backgroundTask)
        }
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        do {
            try scheduleRefresh()
        } catch {
            debugPrint(error)
        }
    }
}
