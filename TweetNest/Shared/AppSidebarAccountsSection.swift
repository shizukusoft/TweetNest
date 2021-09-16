//
//  AppSidebarAccountsSection.swift
//  AppSidebarAccountsSection
//
//  Created by Jaehong Kang on 2021/08/05.
//

import SwiftUI
import TweetNestKit

struct AppSidebarAccountsSection: View {
    @ObservedObject var account: Account
    @Binding var navigationItemSelection: AppSidebarNavigationItem?

    @FetchRequest
    private var users: FetchedResults<User>

    @ViewBuilder
    var accountNavigationLink: some View {
        NavigationLink(
            tag: .profile(account),
            selection: $navigationItemSelection
        ) {
            UserView(user: users.first)
                .environment(\.account, account)
        } label: {
            Label("Account", systemImage: "person")
        }
    }

    @ViewBuilder
    var followingsNavigationLink: some View {
        NavigationLink(
            tag: .followings(account),
            selection: $navigationItemSelection
        ) {
            UsersDiffList(user: users.first, diffKeyPath: \.followingUserIDs, title: Text("Followings History"))
                .environment(\.account, account)
        } label: {
            Label("Followings History", systemImage: "person.2")
        }
    }

    @ViewBuilder
    var followersNavigationLink: some View {
        NavigationLink(
            tag: .followers(account),
            selection: $navigationItemSelection
        ) {
            UsersDiffList(user: users.first, diffKeyPath: \.followerUserIDs, title: Text("Followers History"))
                .environment(\.account, account)
        } label: {
            Label("Followers History", systemImage: "person.2")
        }
    }

    @ViewBuilder
    var blockingsNavigationLink: some View {
        NavigationLink(
            tag: .blockings(account),
            selection: $navigationItemSelection
        ) {
            UsersDiffList(user: users.first, diffKeyPath: \.blockingUserIDs, title: Text("Blocks History"))
                .environment(\.account, account)
        } label: {
            Label("Blocks History", systemImage: "nosign")
        }
    }

    var body: some View {
        Section {
            Group {
                let displayAccountName = users.first?.sortedUserDetails?.last?.displayUsername ?? account.displayUserID ?? account.objectID.description

                accountNavigationLink
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(displayAccountName)'s Account")
                    .accessibilityAddTraits(.isButton)

                followingsNavigationLink
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(displayAccountName)'s Following History")
                    .accessibilityAddTraits(.isButton)

                followersNavigationLink
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(displayAccountName)'s Followers History")
                    .accessibilityAddTraits(.isButton)

                if account.preferences.fetchBlockingUsers {
                    blockingsNavigationLink
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("\(displayAccountName)'s Blocks History")
                        .accessibilityAddTraits(.isButton)
                }
            }
            .onChange(of: account.userID) { newValue in
                if let newValue = newValue {
                    users.nsPredicate = NSPredicate(format: "id == %@", newValue)
                } else {
                    users.nsPredicate = NSPredicate(value: false)
                }
            }
        } header: {
            AccountLabel(account: account)
                #if os(watchOS)
                .padding([.bottom], 2)
                #endif
        }
    }

    init(account: Account, navigationItemSelection: Binding<AppSidebarNavigationItem?>) {
        self.account = account
        self._navigationItemSelection = navigationItemSelection

        self._users = FetchRequest(
            fetchRequest: {
                let fetchRequest = User.fetchRequest()
                if let userID = account.userID {
                    fetchRequest.predicate = NSPredicate(format: "id == %@", userID)
                } else {
                    fetchRequest.predicate = NSPredicate(value: false)
                }
                fetchRequest.sortDescriptors = [
                    NSSortDescriptor(keyPath: \User.creationDate, ascending: false),
                    NSSortDescriptor(keyPath: \User.modificationDate, ascending: false)
                ]
                fetchRequest.propertiesToFetch = ["id"]
                fetchRequest.fetchLimit = 1

                return fetchRequest
            }()
        )
    }
}

//#if DEBUG
//struct AppSidebarAccountRows_Previews: PreviewProvider {
//    static var previews: some View {
//        AppSidebarAccountRows()
//    }
//}
//#endif

