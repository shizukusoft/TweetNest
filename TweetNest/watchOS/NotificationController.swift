//
//  NotificationController.swift
//  TweetNest Extension
//
//  Created by Jaehong Kang on 2021/08/25.
//

import WatchKit
import SwiftUI
import UserNotifications
import OrderedCollections

class NotificationController: WKUserNotificationHostingController<NotificationView> {
    private var notifications: OrderedDictionary<String, (date: Date, request: UNNotificationRequest)> = [:]

    override var body: NotificationView {
        return NotificationView(notifications: Array(notifications.values))
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    override func didReceive(_ notification: UNNotification) {
        // This method is called when a notification needs to be presented.
        // Implement it if you use a dynamic notification interface.
        // Populate your dynamic notification interface as quickly as possible.

        notifications[notification.request.identifier] = (notification.date, notification.request)
    }
}
