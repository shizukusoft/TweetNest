//
//  AppSidebarAccountRows.swift
//  AppSidebarAccountRows
//
//  Created by Jaehong Kang on 2021/08/05.
//

import SwiftUI
import TweetNestKit

struct AppSidebarAccountRows: View {
    @ObservedObject var account: Account
    var lastUserData: UserData? {
        account.user?.sortedUserDatas?.last
    }
    @Binding var navigationItemSelection: AppSidebarNavigation.NavigationItem?

    var body: some View {
        Group {
            NavigationLink(tag: .profile(account), selection: $navigationItemSelection) {
                AccountView(account: account)
            } label: {
                Label("Account", systemImage: "person")
            }
            .accessibilityLabel("Account")

            if let followingUserIDs = lastUserData?.followingUserIDs {
                NavigationLink(tag: .followings(account), selection: $navigationItemSelection) {
                    UsersList(userIDs: followingUserIDs)
                        .navigationTitle(Text("Latest Followings"))
                } label: {
                    Label("Latest Followings", systemImage: "person.2")
                }
                .accessibilityLabel("Latest Followings")
            }

            if let followerUserIDs = lastUserData?.followerUserIDs {
                NavigationLink(tag: .followers(account), selection: $navigationItemSelection) {
                    UsersList(userIDs: followerUserIDs)
                        .navigationTitle(Text("Latest Followers"))
                } label: {
                    Label("Latest Followers", systemImage: "person.2")
                }
                .accessibilityLabel("Latest Followers")
            }

            if let blockingUserIDs = lastUserData?.blockingUserIDs {
                NavigationLink(tag: .blockings(account), selection: $navigationItemSelection) {
                    UsersList(userIDs: blockingUserIDs)
                        .navigationTitle(Text("Latest Blockings"))
                } label: {
                    Label("Latest Blockings", systemImage: "nosign")
                }
                .accessibilityLabel("Latest Blockings")
            }
        }
    }
}

//#if DEBUG
//struct AppSidebarAccountRows_Previews: PreviewProvider {
//    static var previews: some View {
//        AppSidebarAccountRows()
//    }
//}
//#endif
