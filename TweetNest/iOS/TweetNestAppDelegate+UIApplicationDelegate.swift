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

extension TweetNestAppDelegate: UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        if BackgroundTaskScheduler.shared.registerBackgroundTasks() == false {
            Logger().error("Failed to register background tasks")
        }

        application.registerForRemoteNotifications()

        return true
    }

    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        Session.handleEventsForBackgroundURLSession(identifier, completionHandler: completionHandler)
    }
}
