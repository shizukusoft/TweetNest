//
//  UserLabel.swift
//  UserLabel
//
//  Created by Jaehong Kang on 2021/09/13.
//

import SwiftUI
import TweetNestKit

struct UserLabel: View {
    let userDetail: UserDetail?
    let displayUserID: String

    struct Content: View {
        @ObservedObject var userDetail: UserDetail
        let displayUserID: String

        @Environment(\.account) private var account: Account?

        var body: some View {
            Label {
                if let user = userDetail.user {
                    NavigationLink {
                        UserView(user: user)
                            .environment(\.account, account)
                    } label: {
                        userLabelTitle(latestUserDetail: userDetail, displayUserID: displayUserID)
                    }
                } else {
                    userLabelTitle(latestUserDetail: userDetail, displayUserID: displayUserID)
                }
            } icon: {
                ProfileImage(profileImageURL: userDetail.profileImageURL)
                    .frame(width: 24, height: 24)
            }
        }

        @ViewBuilder
        private func userLabelTitle(latestUserDetail: UserDetail, displayUserID: String) -> some View {
            TweetNestStack {
                Text(verbatim: latestUserDetail.name ?? displayUserID)
                    .lineLimit(1)

                if let username = latestUserDetail.username {
                    Text(verbatim: "@\(username)")
                        .lineLimit(1)
                        .layoutPriority(1)
                        .foregroundColor(Color.gray)
                }
            }
        }
    }

    var body: some View {
        if let userDetail = userDetail {
            Content(userDetail: userDetail, displayUserID: displayUserID)
        } else {
            Text(verbatim: displayUserID)
                .lineLimit(1)
        }
    }

    init(userDetail: UserDetail? = nil, displayUserID: String) {
        self.userDetail = userDetail
        self.displayUserID = displayUserID
    }
}

struct UserLabel_Previews: PreviewProvider {
    static var previews: some View {
        UserLabel(userDetail: nil, displayUserID: "#123,456,789")
    }
}
