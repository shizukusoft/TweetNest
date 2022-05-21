//
//  UserDetailLabel.swift
//  TweetNest
//
//  Created by 강재홍 on 2022/04/17.
//

import SwiftUI
import TweetNestKit

struct UserDetailLabel: View {
    private struct _UserDetailLabel: View {
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
            _UserDetailLabel(userDetail: userDetail, placeholder: placeholder, showsName: showsName, showsUsername: showsUsername)
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

#if DEBUG
struct UserDetailLabel_Previews: PreviewProvider {

    private static let _userDetail: ManagedUserDetail = ManagedAccount.preview.users!.last!.userDetails!.last!

    static var previews: some View {
        NavigationView {
            List {
                Section(
                    content: {
                        UserDetailLabel(userDetail: _userDetail, account: .preview)
                        #if os(watchOS)
                        .labelStyle(.userDetailLabelStyle(iconWidth: 16, iconHeight: 16))
                        #elseif os(macOS)
                        .labelStyle(.userDetailLabelStyle(iconWidth: 18, iconHeight: 18))
                        #else
                        .labelStyle(.userDetailLabelStyle(iconWidth: 24, iconHeight: 24))
                        #endif
                    },
                    header: {
                        UserDetailLabel(userDetail: _userDetail, account: .preview)
                        #if os(watchOS)
                        .labelStyle(.userDetailLabelStyle(iconWidth: 16, iconHeight: 16))
                        .padding([.bottom], 2)
                        #elseif os(macOS)
                        .labelStyle(.userDetailLabelStyle(iconWidth: 18, iconHeight: 18))
                        #else
                        .labelStyle(.userDetailLabelStyle(iconWidth: 24, iconHeight: 24))
                        #endif
                    })
            }
            #if os(iOS) || os(macOS)
            .listStyle(.sidebar)
            #endif
            .navigationBarHidden(true)
        }
    }
}
#endif
