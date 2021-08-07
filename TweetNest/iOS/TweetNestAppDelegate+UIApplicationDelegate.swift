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
        UNUserNotificationCenter.current().delegate = self

        if (Session.shared.registerUpdateAccountsBackgroundTask() == false) {
            Logger().error("Failed to register update accounts background task: \(Session.updateAccountsBackgroundTaskIdentifier, privacy: .public)")
        }

        return true
    }
}
