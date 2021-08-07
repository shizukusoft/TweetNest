//
//  AppSidebarAccountRows.swift
//  AppSidebarAccountRows
//
//  Created by Jaehong Kang on 2021/08/05.
//

import SwiftUI
import TweetNestKit

struct AppSidebarAccountRows: View {
    let account: Account
    @Binding var navigationItemSelection: AppSidebarNavigation.NavigationItem?

    var body: some View {
        Group {
            NavigationLink(tag: .profile(account), selection: $navigationItemSelection) {
                AccountView(account: account)
            } label: {
                Label("Account", systemImage: "person")
            }

            if let lastUserData = account.user?.sortedUserDatas?.last {
                userDataView(lastUserData)
            }
        }
    }

    @ViewBuilder
    func userDataView(_ userData: UserData) -> some View {
        if let followingUserIDs = userData.followingUserIDs {
            NavigationLink(tag: .followings(account), selection: $navigationItemSelection) {
                UsersList(userIDs: followingUserIDs)
                    .navigationTitle(Text("Latest Followings"))
            } label: {
                Label("Latest Followings", systemImage: "person.2")
            }
        }

        if let followerUserIDs = userData.followerUserIDs {
            NavigationLink(tag: .followers(account), selection: $navigationItemSelection) {
                UsersList(userIDs: followerUserIDs)
                    .navigationTitle(Text("Latest Followers"))
            } label: {
                Label("Latest Followers", systemImage: "person.2")
            }
        }

        if let blockingUserIDs = userData.blockingUserIDs {
            NavigationLink(tag: .blockings(account), selection: $navigationItemSelection) {
                UsersList(userIDs: blockingUserIDs)
                    .navigationTitle(Text("Latest Blockings"))
            } label: {
                Label("Latest Blockings", systemImage: "nosign")
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
