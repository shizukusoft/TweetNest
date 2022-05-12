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
        @ObservedObject var userDetail: ManagedUserDetail
        let placeholder: String

        let showsName: Bool
        let showsUsername: Bool

        private var names: [String] {
            var names = [String]()

            if showsName, let name = userDetail.name {
                names.append(name)
            }

            if showsUsername, let displayUsername = userDetail.displayUsername {
                names.append(displayUsername)
            }

            return names
        }

        var body: some View {
            let primaryName = names.first ?? placeholder

            Label {
                TweetNestStack {
                    Text(verbatim: primaryName)
                        .lineLimit(1)

                    if names.count > 1 {
                        Text(verbatim: names[1])
                            .lineLimit(1)
                            .layoutPriority(1)
                            .foregroundColor(Color.gray)
                    }
                }
            } icon: {
                ProfileImage(profileImageURL: userDetail.profileImageURL)
            }
            .accessibilityLabel(Text(verbatim: primaryName))
        }
    }

    let userDetail: ManagedUserDetail?
    let placeholder: String
    let showsName: Bool
    let showsUsername: Bool

    var body: some View {
        if let userDetail = userDetail {
            UserDetailLabel(userDetail: userDetail, placeholder: placeholder, showsName: showsName, showsUsername: showsUsername)
        } else {
            Label {
                Text(verbatim: placeholder)
                    .lineLimit(1)
            } icon: {

            }
            .accessibilityLabel(Text(verbatim: placeholder))
        }
    }

    init(userDetail: ManagedUserDetail?, placeholder: String, showsName: Bool = true, showsUsername: Bool = true) {
        self.userDetail = userDetail
        self.placeholder = placeholder
        self.showsName = showsName
        self.showsUsername = showsUsername
    }

    init(userDetail: ManagedUserDetail?, account: ManagedAccount) {
        self.init(
            userDetail: userDetail,
            placeholder: account.userID?.displayUserID ?? account.objectID.uriRepresentation().absoluteString,
            showsName: false,
            showsUsername: true
        )
    }
}

//struct UserDetailLabel_Previews: PreviewProvider {
//    static var previews: some View {
//        UserDetailLabel()
//    }
//}
