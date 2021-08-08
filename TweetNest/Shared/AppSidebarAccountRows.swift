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
            NavigationLink(
                Label(Text("Account"), systemImage: "person"),
                tag: .profile(account),
                selection: $navigationItemSelection)
            {
                AccountView(account: account)
            }
            .accessibilityLabel(Text("Account"))

            if let followingUserIDs = lastUserData?.followingUserIDs {
                NavigationLink(
                    Label(Text("Latest Followings"), systemImage: "person.2"),
                    tag: .followings(account),
                    selection: $navigationItemSelection)
                {
                    UsersList(userIDs: followingUserIDs)
                    .navigationTitle(Text("Latest Followings"))
                }
                .accessibilityLabel(Text("Latest Followings"))
            }

            if let followerUserIDs = lastUserData?.followerUserIDs {
                NavigationLink(
                    Label(Text("Latest Followers"), systemImage: "person.2"),
                    tag: .followers(account),
                    selection: $navigationItemSelection)
                {
                    UsersList(userIDs: followerUserIDs)
                    .navigationTitle(Text("Latest Followers"))
                }
                .accessibilityLabel(Text("Latest Followers"))
            }

            if let blockingUserIDs = lastUserData?.blockingUserIDs {
                NavigationLink(
                    Label(Text("Latest Blocked Accounts"), systemImage: "nosign"),
                    tag: .blockings(account),
                    selection: $navigationItemSelection)
                {
                    UsersList(userIDs: blockingUserIDs)
                    .navigationTitle(Text("Latest Blocked Accounts"))
                }
                .accessibilityLabel(Text("Latest Blocked Accounts"))
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
