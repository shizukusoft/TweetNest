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
        NavigationLink(tag: .profile(account), selection: $navigationItemSelection) {
            AccountView(account: account)
        } label: {
            Label("Account", systemImage: "person")
        }

        NavigationLink(tag: .followings(account), selection: $navigationItemSelection) {
            UsersList(userIDs: account.user?.sortedUserDatas?.last?.followingUserIDs ?? [])
                .navigationTitle(Text("Followings"))
        } label: {
            Label("Followings", systemImage: "person.2")
        }

        NavigationLink(tag: .followers(account), selection: $navigationItemSelection) {
            UsersList(userIDs: account.user?.sortedUserDatas?.last?.followerUserIDs ?? [])
                .navigationTitle(Text("Followers"))
        } label: {
            Label("Followers", systemImage: "person.2")
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
