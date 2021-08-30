//
//  TweetNestAppDelegate.swift
//  TweetNestAppDelegate
//
//  Created by Jaehong Kang on 2021/08/25.
//

import WatchKit
import UserNotifications

extension TweetNestAppDelegate: WKExtensionDelegate {
    func applicationDidFinishLaunching() {
        UNUserNotificationCenter.current().delegate = self
    }
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        session.handleBackgroundRefreshBackgroundTask(backgroundTasks)
    }
}
