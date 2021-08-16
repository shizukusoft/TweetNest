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
    @Binding var navigationItemSelection: AppSidebarNavigation.NavigationItem?

    var body: some View {
        Group {
            NavigationLink(
                Label(Text("Account"), systemImage: "person"),
                tag: .profile(account),
                selection: $navigationItemSelection)
            {
                UserView(user: account.user)
                    .environment(\.account, account)
            }
            .accessibilityLabel(Text("Account"))

            if let user = account.user {
                NavigationLink(
                    Label(Text("Following History"), systemImage: "person.2"),
                    tag: .followings(account),
                    selection: $navigationItemSelection)
                {
                    UsersDiffList(user: user, diffKeyPath: \.followingUserIDs)
                        .environment(\.account, account)
                        .navigationTitle(Text("Following History"))
                }
                .accessibilityLabel(Text("Following History"))

                NavigationLink(
                    Label(Text("Follower History"), systemImage: "person.2"),
                    tag: .followers(account),
                    selection: $navigationItemSelection)
                {
                    UsersDiffList(user: user, diffKeyPath: \.followerUserIDs)
                        .environment(\.account, account)
                        .navigationTitle(Text("Follower History"))
                }
                .accessibilityLabel(Text("Follower History"))

                if account.preferences.fetchBlockingUsers {
                    NavigationLink(
                        Label(Text("Blocking History"), systemImage: "nosign"),
                        tag: .blockings(account),
                        selection: $navigationItemSelection)
                    {
                        UsersDiffList(user: user, diffKeyPath: \.blockingUserIDs)
                            .environment(\.account, account)
                            .navigationTitle(Text("Blocking History"))
                    }
                    .accessibilityLabel(Text("Blocking History"))
                }
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

