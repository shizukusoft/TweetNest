//
//  UserDetailView.swift
//  UserDetailView
//
//  Created by Jaehong Kang on 2021/08/04.
//

import SwiftUI
import TweetNestKit

struct UserDetailView: View {
    @Environment(\.account) var account: ManagedAccount?
    @ObservedObject var userDetail: ManagedUserDetail

    @ViewBuilder
    var followingUsersLabel: some View {
        Label {
            HStack {
                Text("Followings")
                Spacer()
                Text(userDetail.followingUsersCount.twnk_formatted())
                    .foregroundColor(Color.secondary)
                    .lineLimit(1)
                    .allowsTightening(true)
            }
        } icon: {
            Image(systemName: "person.2")
        }
        .accessibilityLabel("Followings")
    }

    @ViewBuilder
    var followersLabel: some View {
        Label {
            HStack {
                Text("Followers")
                Spacer()
                Text(userDetail.followerUsersCount.twnk_formatted())
                    .foregroundColor(Color.secondary)
                    .lineLimit(1)
                    .allowsTightening(true)
            }
        } icon: {
            Image(systemName: "person.2")
        }
        .accessibilityLabel("Followers")
    }

    var body: some View {
        List {
            Section(String(localized: "Profile")) {
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
                        Label {
                            HStack {
                                Text("Blocked Accounts")
                                Spacer()
                                Text(blockingUserIDs.count.twnk_formatted())
                                    .foregroundColor(Color.secondary)
                                    .lineLimit(1)
                                    .allowsTightening(true)
                            }
                        } icon: {
                            Image(systemName: "nosign")
                        }
                    }
                }

                if let mutingUserIDs = userDetail.mutingUserIDs {
                    NavigationLink(
                        destination: {
                            UsersList(userIDs: mutingUserIDs)
                            .navigationTitle(Text("Muted Accounts"))
                            .environment(\.account, account)
                        },
                        label: {
                            Label(
                                title: {
                                    HStack {
                                        Text("Muted Accounts")
                                        Spacer()
                                        Text(mutingUserIDs.count.twnk_formatted())
                                        .allowsTightening(true)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                    }
                                },
                                icon: {
                                    Image(systemName: "speaker.slash")
                                })
                        })
                }
            }

            Section {
                Label {
                    HStack {
                        Text("Listed")
                        Spacer()
                        Text(userDetail.listedCount.twnk_formatted())
                            .foregroundColor(Color.secondary)
                            .lineLimit(1)
                            .allowsTightening(true)
                    }
                } icon: {
                    Image(systemName: "list.bullet")
                }
                .accessibilityLabel(Text("Listed"))
            }

            Section {
                Label {
                    HStack {
                        Text("Tweets")
                        Spacer()
                        Text(userDetail.tweetsCount.twnk_formatted())
                            .foregroundColor(Color.secondary)
                            .lineLimit(1)
                            .allowsTightening(true)
                    }
                } icon: {
                    Image(systemName: "text.bubble")
                }
                .accessibilityLabel(Text("Tweets"))
            }
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

 #if DEBUG
 struct UserDetailView_Previews: PreviewProvider {

    static var previews: some View {
        NavigationView {
            UserDetailView(userDetail: .preview)
            .environment(\.account, .preview)
            .navigationBarHidden(true)
        }
    }
 }
 #endif
