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

extension UISplitViewController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        preferredDisplayMode = .twoBesideSecondary
    }
}

extension TweetNestAppDelegate: UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self

        if (BackgroundTaskScheduler.shared.registerBackgroundTasks() == false) {
            Logger().error("Failed to register background tasks")
        }

        return true
    }
}
