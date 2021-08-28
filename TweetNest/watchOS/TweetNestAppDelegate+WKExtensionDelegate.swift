//
//  TweetNestAppDelegate.swift
//  TweetNestAppDelegate
//
//  Created by Jaehong Kang on 2021/08/25.
//

import WatchKit

extension TweetNestAppDelegate: WKExtensionDelegate {
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        let handledBackgroundTasksBySession = session.handleBackgroundRefresh(backgroundTasks)
        
        for task in backgroundTasks.subtracting(handledBackgroundTasksBySession) {
            task.setTaskCompletedWithSnapshot(false)
        }
    }
}
