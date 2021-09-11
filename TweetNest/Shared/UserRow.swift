//
//  UserRow.swift
//  UserRow
//
//  Created by Jaehong Kang on 2021/08/09.
//

import SwiftUI
import TweetNestKit

struct UserRow: View {
    @Environment(\.account) private var account: Account?

    @ObservedObject var user: User

    var body: some View {
        if let latestUserDetail = user.sortedUserDetails?.last {
            Label {
                NavigationLink {
                    UserView(user: user)
                        .environment(\.account, account)
                } label: {
                    TweetNestStack {
                        userLabelTitle(latestUserDetail: latestUserDetail, user: user)
                    }
                }
                .accessibilityLabel(Text(verbatim: latestUserDetail.name ?? user.id.flatMap { "#\($0)" } ?? user.objectID.description))
            } icon: {
                ProfileImage(userDetail: latestUserDetail)
                    .frame(width: 24, height: 24)
            }
            #if os(watchOS)
            .labelStyle(.titleOnly)
            #endif
        }
    }

    @ViewBuilder
    func userLabelTitle(latestUserDetail: UserDetail, user: User) -> some View {
        Text(verbatim: latestUserDetail.name ?? user.id.flatMap { "#\($0)" } ?? user.objectID.description)
            .lineLimit(1)

        if let username = latestUserDetail.username {
            Text(verbatim: "@\(username)")
                .lineLimit(1)
                .layoutPriority(1)
                .foregroundColor(Color.gray)
        }
    }
}

//struct UserRow_Previews: PreviewProvider {
//    static var previews: some View {
//        UserRow()
//    }
//}
