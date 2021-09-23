//
//  NotificationController.swift
//  TweetNest Extension
//
//  Created by Jaehong Kang on 2021/08/25.
//

import WatchKit
import SwiftUI
import UserNotifications

class NotificationController: WKUserNotificationHostingController<NotificationView> {

    var title: String?
    var subtitle: String?
    var message: String?

    override var body: NotificationView {
        return NotificationView(title: title, subtitle: subtitle, message: message)
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

        self.title = notification.request.content.title
        self.subtitle = notification.request.content.subtitle
        self.message = notification.request.content.body
    }
}
