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
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Session.refreshBackgroundTaskIdentifier, using: nil) { backgroundTask in
            Session.shared.refresh(backgroundTask: backgroundTask)
        }
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        do {
            try Session.shared.scheduleRefresh()
        } catch {
            Logger().error("Error occured while schedule refresh: \(String(describing: error))")
        }
    }
}
