//
//  NotificationView.swift
//  TweetNest Extension
//
//  Created by Jaehong Kang on 2021/08/25.
//

import SwiftUI
import UserNotifications
import OrderedCollections

struct NotificationView: View {
    let notifications: OrderedDictionary<String, OrderedDictionary<String, [(date: Date, request: UNNotificationRequest)]>>

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(notifications.elements, id: \.key) { notifications in
                Text(verbatim: notifications.key)
                    .font(.headline)

                VStack(alignment: .leading) {
                    ForEach(notifications.value.elements, id: \.key) { notifications in
                        Text(verbatim: notifications.key)
                            .font(.headline)

                        VStack(alignment: .leading) {
                            ForEach(notifications.value, id: \.request.identifier) { notification in
                                if let message = notification.request.content.body, message.isEmpty == false {
                                    HStack {
                                        Text(verbatim: message)

                                        Spacer()

                                        Text("\(notification.date, style: .relative) ago")
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .lineLimit(0)
    }
}

// struct NotificationView_Previews: PreviewProvider {
//    static var previews: some View {
//        NotificationView(notifications: [
//            (
//                date: Date(),
//                request: UNNotificationRequest(
//                    identifier: "abcd",
//                    content: {
//                        let content = UNMutableNotificationContent()
//                        content.title = "TweetNest (@TweetNest_App)"
//                        content.subtitle = "New Data Available"
//                        content.body = "1 new followings"
//
//                        return content
//                    }(),
//                    trigger: nil
//                )
//            )
//        ])
//    }
// }
