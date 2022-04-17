//
//  UserView+AllDataView.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/09/23.
//

import SwiftUI
import TweetNestKit

extension UserView {
    struct AllDataView: View {
        @Environment(\.account) var account: Account?

        let userDetails: [UserDetail]
        
        var body: some View {
            #if os(macOS)
            Table(userDetails) {
                TableColumn("Date") { userDetail in
                    Text(userDetail.creationDate?.formatted(date: .abbreviated, time: .standard) ?? "")
                }
                TableColumn("Profile Image") { userDetail in
                    ProfileImage(profileImageURL: userDetail.profileImageURL)
                        .frame(width: 24, height: 24)
                }
                TableColumn("Name") { userDetail in
                    Text(userDetail.name ?? "")
                }
                TableColumn("Username") { userDetail in
                    Text(verbatim: userDetail.username.flatMap { "@\($0)" } ?? "")
                }
                TableColumn("Location") { userDetail in
                    Text(userDetail.location ?? "")
                }
                TableColumn("URL") { userDetail in
                    if let url = userDetail.url {
                        Link(url.absoluteString, destination: url)
                    } else {
                        Text("")
                    }
                }
                TableColumn("Followings") { userDetail in
                    Text(userDetail.followingUsersCount.twnk_formatted())
                }
                TableColumn("Followers") { userDetail in
                    Text(userDetail.followerUsersCount.twnk_formatted())
                }

                TableColumn("Listed") { userDetail in
                    Text(userDetail.listedCount.twnk_formatted())
                }
                TableColumn("Tweets") { userDetail in
                    Text(userDetail.tweetsCount.twnk_formatted())
                }
            }
            #else
            ForEach(userDetails) { userDetail in
                NavigationLink(
                    userDetail.creationDate?.formatted(date: .abbreviated, time: .standard) ?? userDetail.objectID.description
                ) {
                    UserDetailView(userDetail: userDetail)
                        .navigationTitle(
                            Text(userDetail.creationDate?.formatted(date: .abbreviated, time: .standard) ?? userDetail.objectID.description)
                            .accessibilityLabel(Text(userDetail.creationDate?.formatted(date: .complete, time: .standard) ?? userDetail.objectID.description))
                        )
                        .environment(\.account, account)
                }
            }
            #endif
        }
    }
}

struct UserViewAllDataView_Previews: PreviewProvider {
    static var previews: some View {
        UserView.AllDataView(userDetails: [])
    }
}
