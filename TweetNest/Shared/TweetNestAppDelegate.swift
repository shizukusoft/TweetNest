//
//  TweetNestAppDelegate.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/03/22.
//

import Foundation
import UserNotifications
import TweetNestKit
import UnifiedLogging

@MainActor
class TweetNestAppDelegate: NSObject, ObservableObject {
    let session = Session.shared

    override init() {
        super.init()

        Task.detached(priority: .utility) {
            do {
                try await BackgroundTaskScheduler.shared.scheduleBackgroundTasks(for: .active)

            } catch {
                Logger().error("Error occurred while schedule refresh: \(String(reflecting: error), privacy: .public)")
            }
        }
    }
}

extension TweetNestAppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.badge, .sound, .list, .banner]
    }
}
