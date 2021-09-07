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
                Label {
                    Text("Account")
                } icon: {
                    Image(systemName: "person")
                },
                tag: .profile(account),
                selection: $navigationItemSelection)
            {
                UserView(user: account.user)
                    .environment(\.account, account)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("\(account.user?.displayUsername ?? account.objectID.description)'s Account"))
            .accessibilityAddTraits(.isButton)

            if let user = account.user {
                NavigationLink(
                    Label {
                        Text("Followings History")
                    } icon: {
                        Image(systemName: "person.2")
                    },
                    tag: .followings(account),
                    selection: $navigationItemSelection)
                {
                    UsersDiffList(user: user, diffKeyPath: \.followingUserIDs, title: Text("Followings History"))
                        .environment(\.account, account)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text("\(account.user?.displayUsername ?? account.objectID.description)'s Following History"))
                .accessibilityAddTraits(.isButton)

                NavigationLink(
                    Label {
                        Text("Followers History")
                    } icon: {
                        Image(systemName: "person.2")
                    },
                    tag: .followers(account),
                    selection: $navigationItemSelection)
                {
                    UsersDiffList(user: user, diffKeyPath: \.followerUserIDs, title: Text("Followers History"))
                        .environment(\.account, account)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text("\(account.user?.displayUsername ?? account.objectID.description)'s Followers History"))
                .accessibilityAddTraits(.isButton)

                if account.preferences.fetchBlockingUsers {
                    NavigationLink(
                        Label {
                            Text("Blocks History")
                        } icon: {
                            Image(systemName: "nosign")
                        },
                        tag: .blockings(account),
                        selection: $navigationItemSelection)
                    {
                        UsersDiffList(user: user, diffKeyPath: \.blockingUserIDs, title: Text("Blocks History"))
                            .environment(\.account, account)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(Text("\(account.user?.displayUsername ?? account.objectID.description)'s Blocks History"))
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

