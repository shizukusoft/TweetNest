//
//  UserDetailLabel.swift
//  TweetNest
//
//  Created by 강재홍 on 2022/04/17.
//

import SwiftUI
import TweetNestKit

struct UserDetailLabel: View {
    private struct UserDetailLabel: View {
        @ObservedObject var userDetail: UserDetail
        let placeholder: String
        let showsUsernameOnly: Bool

        var body: some View {
            let name = (showsUsernameOnly ? userDetail.displayUsername : userDetail.name) ?? placeholder

            Label {
                TweetNestStack {
                    Text(verbatim: name)
                        .lineLimit(1)

                    if showsUsernameOnly == false, let username = userDetail.username {
                        Text(verbatim: "@\(username)")
                            .lineLimit(1)
                            .layoutPriority(1)
                            .foregroundColor(Color.gray)
                    }
                }
            } icon: {
                ProfileImage(profileImageURL: userDetail.profileImageURL)
                    #if os(watchOS)
                    .frame(width: 16, height: 16)
                    #else
                    .frame(width: 24, height: 24)
                    #endif
            }
            .accessibilityLabel(Text(verbatim: name))
        }
    }

    let userDetail: UserDetail?
    let placeholder: String
    let showsUsernameOnly: Bool

    var body: some View {
        if let userDetail = userDetail {
            UserDetailLabel(userDetail: userDetail, placeholder: placeholder, showsUsernameOnly: showsUsernameOnly)
        } else {
            Label {
                Text(verbatim: placeholder)
                    .lineLimit(1)
            } icon: {

            }
            .accessibilityLabel(Text(verbatim: placeholder))
        }
    }

    init(userDetail: UserDetail?, placeholder: String, showsUsernameOnly: Bool = false) {
        self.userDetail = userDetail
        self.placeholder = placeholder
        self.showsUsernameOnly = showsUsernameOnly
    }

    init(userDetail: UserDetail?, account: Account) {
        self.userDetail = userDetail
        self.placeholder = account.userID?.displayUserID ?? account.objectID.uriRepresentation().absoluteString
        self.showsUsernameOnly = true
    }
}

//struct UserDetailLabel_Previews: PreviewProvider {
//    static var previews: some View {
//        UserDetailLabel()
//    }
//}
