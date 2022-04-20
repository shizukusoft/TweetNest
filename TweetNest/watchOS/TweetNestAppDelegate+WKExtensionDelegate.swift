//
//  TweetNestAppDelegate.swift
//  TweetNestAppDelegate
//
//  Created by Jaehong Kang on 2021/08/25.
//

import WatchKit
import TweetNestKit
import UserNotifications

extension TweetNestAppDelegate: WKExtensionDelegate {
    func applicationDidFinishLaunching() {
        UNUserNotificationCenter.current().delegate = self
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        let handledBackgroundTasks = BackgroundTaskScheduler.shared.handleBackgroundRefreshBackgroundTask(backgroundTasks)

        for backgroundTask in backgroundTasks.subtracting(handledBackgroundTasks) {
            switch backgroundTask {
            case let backgroundTask as WKSnapshotRefreshBackgroundTask:
                DispatchQueue.main.async {
                    backgroundTask.setTaskCompleted(restoredDefaultState: false, estimatedSnapshotExpiration: .distantFuture, userInfo: nil)
                }
            case let backgroundTask as WKURLSessionRefreshBackgroundTask:
                Session.handleEventsForBackgroundURLSession(backgroundTask.sessionIdentifier) {
                    backgroundTask.setTaskCompletedWithSnapshot(true)
                }
            default:
                break
            }
        }
    }
}
