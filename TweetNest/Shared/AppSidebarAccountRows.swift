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

    var body: some View {
        Group {
            let displayAccountName = users.first?.sortedUserDetails?.last?.displayUsername ?? account.displayUserID ?? account.objectID.description

            accountNavigationLink
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(displayAccountName)'s Account")
                .accessibilityAddTraits(.isButton)

            if let user = users.first {
                followingsNavigationLink(user: user)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(displayAccountName)'s Following History")
                    .accessibilityAddTraits(.isButton)

                followersNavigationLink(user: user)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(displayAccountName)'s Followers History")
                    .accessibilityAddTraits(.isButton)

                if account.preferences.fetchBlockingUsers {
                    blockingsNavigationLink(user: user)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("\(displayAccountName)'s Blocks History")
                        .accessibilityAddTraits(.isButton)
                }
            }
        }
        .onChange(of: account.userID) { newValue in
            if let newValue = newValue {
                users.nsPredicate = NSPredicate(format: "id == %@", newValue)
            } else {
                users.nsPredicate = NSPredicate(value: false)
            }
        }
    }

    init(account: Account, navigationItemSelection: Binding<AppSidebarNavigation.NavigationItem?>) {
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

    @ViewBuilder
    func followingsNavigationLink(user: User) -> some View {
        NavigationLink(
            tag: .followings(account),
            selection: $navigationItemSelection
        ) {
            UsersDiffList(user: user, diffKeyPath: \.followingUserIDs, title: Text("Followings History"))
                .environment(\.account, account)
        } label: {
            Label("Followings History", systemImage: "person.2")
        }
    }

    @ViewBuilder
    func followersNavigationLink(user: User) -> some View {
        NavigationLink(
            tag: .followers(account),
            selection: $navigationItemSelection
        ) {
            UsersDiffList(user: user, diffKeyPath: \.followerUserIDs, title: Text("Followers History"))
                .environment(\.account, account)
        } label: {
            Label("Followers History", systemImage: "person.2")
        }
    }

    @ViewBuilder
    func blockingsNavigationLink(user: User) -> some View {
        NavigationLink(
            tag: .blockings(account),
            selection: $navigationItemSelection
        ) {
            UsersDiffList(user: user, diffKeyPath: \.blockingUserIDs, title: Text("Blocks History"))
                .environment(\.account, account)
        } label: {
            Label("Blocks History", systemImage: "nosign")
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

