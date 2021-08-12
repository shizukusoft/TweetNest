//
//  UserDataView.swift
//  UserDataView
//
//  Created by Jaehong Kang on 2021/08/04.
//

import SwiftUI
import TweetNestKit

struct UserDataView: View {
    @ObservedObject var userData: UserData

    @ViewBuilder
    var followingUsersLabel: some View {
        HStack {
            Label(Text("Followings"), systemImage: "person.2")
            .accessibilityLabel(Text("Followings"))
            Spacer()
            Text(userData.followingUsersCount.formatted())
                .foregroundColor(Color.gray)
        }
    }

    @ViewBuilder
    var followersLabel: some View {
        HStack {
            Label(Text("Followers"), systemImage: "person.2")
            .accessibilityLabel(Text("Followers"))
            Spacer()
            Text(userData.followersCount.formatted())
                .foregroundColor(Color.gray)
        }
    }

    var body: some View {
        List {
            Section(Text("Profile")) {
                UserDataProfileView(userData: userData)
            }

            Section {
                if let followingUserIDs = userData.followingUserIDs {
                    NavigationLink {
                        UsersList(userIDs: followingUserIDs)
                            .navigationTitle(Text("Followings"))
                    } label: {
                        followingUsersLabel
                    }
                } else {
                    followingUsersLabel
                }

                if let followerUserIDs = userData.followerUserIDs {
                    NavigationLink {
                        UsersList(userIDs: followerUserIDs)
                            .navigationTitle(Text("Followers"))
                    } label: {
                        followersLabel
                    }
                } else {
                    followersLabel
                }

                if let blockingUserIDs = userData.blockingUserIDs {
                    NavigationLink {
                        UsersList(userIDs: blockingUserIDs)
                            .navigationTitle(Text("Blocked Accounts"))
                    } label: {
                        HStack {
                            Label(Text("Blocked Accounts"), systemImage: "nosign")
                            Spacer()
                            Text(blockingUserIDs.count.formatted())
                                .foregroundColor(Color.gray)
                        }
                    }
                }
            }

            Section {
                HStack {
                    Label(Text("Listed"), systemImage: "list.bullet")
                    .accessibilityLabel(Text("Listed"))
                    Spacer()
                    Text(userData.listedCount.formatted())
                        .foregroundColor(Color.gray)
                }
            }

            Section {
                HStack {
                    Label(Text("Tweets"), systemImage: "text.bubble")
                    .accessibilityLabel(Text("Tweets"))
                    Spacer()
                    Text(userData.tweetsCount.formatted())
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
//struct UserDataView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserDataView()
//    }
//}
//#endif
