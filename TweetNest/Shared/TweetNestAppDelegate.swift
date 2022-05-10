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
class TweetNestAppDelegate: NSObject, ObservableObject { }

extension TweetNestAppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.badge, .sound, .list, .banner]
    }
}
