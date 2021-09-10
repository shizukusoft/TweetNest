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
                tag: .profile(account),
                selection: $navigationItemSelection
            ) {
                UserView(user: account.user)
                    .environment(\.account, account)
            } label: {
                Label("Account", systemImage: "person")
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(account.user?.displayUsername ?? account.objectID.description)'s Account")
            .accessibilityAddTraits(.isButton)

            if let user = account.user {
                NavigationLink(
                    tag: .followings(account),
                    selection: $navigationItemSelection
                ) {
                    UsersDiffList(user: user, diffKeyPath: \.followingUserIDs, title: Text("Followings History"))
                        .environment(\.account, account)
                } label: {
                    Label("Followings History", systemImage: "person.2")
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(account.user?.displayUsername ?? account.objectID.description)'s Following History")
                .accessibilityAddTraits(.isButton)

                NavigationLink(
                    tag: .followers(account),
                    selection: $navigationItemSelection
                ) {
                    UsersDiffList(user: user, diffKeyPath: \.followerUserIDs, title: Text("Followers History"))
                        .environment(\.account, account)
                } label: {
                    Label("Followers History", systemImage: "person.2")
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(account.user?.displayUsername ?? account.objectID.description)'s Followers History")
                .accessibilityAddTraits(.isButton)

                if account.preferences.fetchBlockingUsers {
                    NavigationLink(
                        tag: .blockings(account),
                        selection: $navigationItemSelection
                    ) {
                        UsersDiffList(user: user, diffKeyPath: \.blockingUserIDs, title: Text("Blocks History"))
                            .environment(\.account, account)
                    } label: {
                        Label("Blocks History", systemImage: "nosign")
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(account.user?.displayUsername ?? account.objectID.description)'s Blocks History")
                    .accessibilityAddTraits(.isButton)
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

