//
//  NotificationView.swift
//  TweetNest Extension
//
//  Created by Jaehong Kang on 2021/08/25.
//

import SwiftUI

struct NotificationView: View {
    let title: String?
    let subtitle: String?
    let message: String?

    var body: some View {
        VStack {
            if let title = title {
                Text(verbatim: title)
                    .font(.headline)
            }

            if let subtitle = subtitle {
                Text(verbatim: subtitle)
                    .font(.subheadline)
            }

            if let message = message {
                Text(verbatim: message)
            }
        }
        .lineLimit(0)
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView(title: "TweetNest (@TweetNest_App)", subtitle: "New Data Available", message: "1 new followings")
    }
}
