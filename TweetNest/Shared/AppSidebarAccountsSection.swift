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

    private var user: User? {
        users.first
    }

    @ViewBuilder
    var accountNavigationLink: some View {
        NavigationLink(
            tag: .profile(account),
            selection: $navigationItemSelection
        ) {
            if let userID = user?.id {
                UserView(userID: userID)
                    .environment(\.account, account)
            }
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
            UsersDiffList(user: user, diffKeyPath: \.followingUserIDs, title: Text("Followings History"))
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
            UsersDiffList(user: user, diffKeyPath: \.followerUserIDs, title: Text("Followers History"))
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
            UsersDiffList(user: user, diffKeyPath: \.blockingUserIDs, title: Text("Blocks History"))
                .environment(\.account, account)
        } label: {
            Label("Blocks History", systemImage: "nosign")
        }
    }

    var body: some View {
        Section {
            Group {
                let displayAccountName = user?.sortedUserDetails?.last?.displayUsername ?? account.displayUserID ?? account.objectID.description

                let accountTitle = String(localized: "Account for \(displayAccountName)", comment: "Navigation link for account, grouped by username.")
                accountNavigationLink
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(accountTitle)
                    .accessibilityIdentifier("\(displayAccountName):Account")
                    .accessibilityAddTraits(.isButton)

                let followingsTitle = String(localized: "Followings History for \(displayAccountName)", comment: "Navigation link for followings history, grouped by username.")
                followingsNavigationLink
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(followingsTitle)
                    .accessibilityIdentifier("\(displayAccountName):FollowingsHistory")
                    .accessibilityAddTraits(.isButton)

                let followersTitle = String(localized: "Followers History for \(displayAccountName)", comment: "Navigation link for followers history, grouped by username.")
                followersNavigationLink
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(followersTitle)
                    .accessibilityIdentifier("\(displayAccountName):FollowersHistory")
                    .accessibilityAddTraits(.isButton)

                if account.preferences.fetchBlockingUsers {
                    let blockingTitle = String(localized: "Blocks History for \(displayAccountName)", comment: "Navigation link for blocks history, grouped by username.")
                    blockingsNavigationLink
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(blockingTitle)
                        .accessibilityIdentifier("\(displayAccountName):BlocksHistory")
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
                    NSSortDescriptor(keyPath: \User.modificationDate, ascending: false),
                    NSSortDescriptor(keyPath: \User.creationDate, ascending: false),
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

