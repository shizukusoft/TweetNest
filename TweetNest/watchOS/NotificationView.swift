//
//  NotificationView.swift
//  TweetNest Extension
//
//  Created by Jaehong Kang on 2021/08/25.
//

import SwiftUI
import UserNotifications

struct NotificationView: View {
    let notifications: [(date: Date, request: UNNotificationRequest)]

    var body: some View {
        List(notifications, id: \.request.identifier) { notification in
            let title = notification.request.content.title
            let subtitle = notification.request.content.subtitle
            let message = notification.request.content.body

            VStack(alignment: .leading) {
                if let title = title, title.isEmpty == false {
                    Text(verbatim: title)
                        .font(.headline)
                }

                if let subtitle = subtitle, subtitle.isEmpty == false {
                    Text(verbatim: subtitle)
                        .font(.subheadline)
                }

                if let message = message, message.isEmpty == false {
                    Text(verbatim: message)
                        .foregroundColor(.secondary)
                }
            }
            .lineLimit(0)
        }
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView(notifications: [
            (
                date: Date(),
                request: UNNotificationRequest(
                    identifier: "abcd",
                    content: {
                        let content = UNMutableNotificationContent()
                        content.title = "TweetNest (@TweetNest_App)"
                        content.subtitle = "New Data Available"
                        content.body = "1 new followings"

                        return content
                    }(),
                    trigger: nil
                )
            )
        ])
    }
}
