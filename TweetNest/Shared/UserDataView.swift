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
            Label("Following", systemImage: "person.2")
            Spacer()
            Text(userData.followingUsersCount.formatted())
                .foregroundColor(Color.gray)
        }
    }

    @ViewBuilder
    var followersLabel: some View {
        HStack {
            Label("Followers", systemImage: "person.2")
            Spacer()
            Text(userData.followersCount.formatted())
                .foregroundColor(Color.gray)
        }
    }

    var body: some View {
        List {
            Section("Profile") {
                UserDataProfileView(userData: userData)
            }

            Section {
                if let followingUserIDs = userData.followingUserIDs, followingUserIDs.isEmpty == false {
                    NavigationLink {
                        UsersList(userIDs: followingUserIDs)
                            .navigationTitle(Text("Followings"))
                    } label: {
                        followingUsersLabel
                    }
                } else {
                    followingUsersLabel
                }

                if let followerUserIDs = userData.followerUserIDs, followerUserIDs.isEmpty == false {
                    NavigationLink {
                        UsersList(userIDs: followerUserIDs)
                            .navigationTitle(Text("Followers"))
                    } label: {
                        followersLabel
                    }
                } else {
                    followersLabel
                }

                if let blockingUserIDs = userData.blockingUserIDs, blockingUserIDs.isEmpty == false {
                    NavigationLink {
                        UsersList(userIDs: blockingUserIDs)
                            .navigationTitle(Text("Blockings"))
                    } label: {
                        HStack {
                            Label("Blockings", systemImage: "nosign")
                            Spacer()
                            Text(blockingUserIDs.count.formatted())
                                .foregroundColor(Color.gray)
                        }
                    }
                }
            }

            Section {
                HStack {
                    Label("Listed", systemImage: "list.bullet")
                    Spacer()
                    Text(userData.listedCount.formatted())
                        .foregroundColor(Color.gray)
                }
            }

            Section {
                HStack {
                    Label("Tweets", systemImage: "text.bubble")
                    Spacer()
                    Text(userData.tweetsCount.formatted())
                        .foregroundColor(Color.gray)
                }
            }
        }
    }
}

//#if DEBUG
//struct UserDataView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserDataView()
//    }
//}
//#endif
