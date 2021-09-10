//
//  UserDetailView.swift
//  UserDetailView
//
//  Created by Jaehong Kang on 2021/08/04.
//

import SwiftUI
import TweetNestKit

struct UserDetailView: View {
    @Environment(\.account) var account: Account?
    @ObservedObject var userDetail: UserDetail

    @ViewBuilder
    var followingUsersLabel: some View {
        HStack {
            Label("Followings", systemImage: "person.2")
            .accessibilityLabel("Followings")
            Spacer()
            Text(userDetail.followingUsersCount.twnk_formatted())
                .foregroundColor(Color.gray)
        }
    }

    @ViewBuilder
    var followersLabel: some View {
        HStack {
            Label("Followers", systemImage: "person.2")
            .accessibilityLabel("Followers")
            Spacer()
            Text(userDetail.followerUsersCount.twnk_formatted())
                .foregroundColor(Color.gray)
        }
    }

    var body: some View {
        List {
            Section("Profile") {
                UserDetailProfileView(userDetail: userDetail)
            }

            Section {
                if let followingUserIDs = userDetail.followingUserIDs {
                    NavigationLink {
                        UsersList(userIDs: followingUserIDs)
                            .navigationTitle("Followings")
                            .environment(\.account, account)
                    } label: {
                        followingUsersLabel
                    }
                } else {
                    followingUsersLabel
                }

                if let followerUserIDs = userDetail.followerUserIDs {
                    NavigationLink {
                        UsersList(userIDs: followerUserIDs)
                            .navigationTitle(Text("Followers"))
                            .environment(\.account, account)
                    } label: {
                        followersLabel
                    }
                } else {
                    followersLabel
                }

                if let blockingUserIDs = userDetail.blockingUserIDs {
                    NavigationLink {
                        UsersList(userIDs: blockingUserIDs)
                            .navigationTitle(Text("Blocked Accounts"))
                            .environment(\.account, account)
                    } label: {
                        HStack {
                            Label("Blocked Accounts", systemImage: "nosign")
                            Spacer()
                            Text(blockingUserIDs.count.twnk_formatted())
                                .foregroundColor(Color.gray)
                        }
                    }
                }
            }

            Section {
                HStack {
                    Label("Listed", systemImage: "list.bullet")
                    .accessibilityLabel(Text("Listed"))
                    Spacer()
                    Text(userDetail.listedCount.twnk_formatted())
                        .foregroundColor(Color.gray)
                }
            }

            Section {
                HStack {
                    Label("Tweets", systemImage: "text.bubble")
                    .accessibilityLabel(Text("Tweets"))
                    Spacer()
                    Text(userDetail.tweetsCount.twnk_formatted())
                        .foregroundColor(Color.gray)
                }
            }
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

//#if DEBUG
//struct UserDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserDetailView()
//    }
//}
//#endif
