//
//  AppSidebarAccountsSection.swift
//  AppSidebarAccountsSection
//
//  Created by Jaehong Kang on 2021/08/05.
//

import SwiftUI
import CoreData
import TweetNestKit

struct AppSidebarAccountsSection: View {
    @ObservedObject var account: Account
    @Binding var navigationItemSelection: AppSidebarNavigationItem?

    @StateObject private var usersFetchedResultsController: FetchedResultsController<User>

    var body: some View {
        Section {
            sectionRows
        } header: {
            AccountLabel(account: account)
                #if os(watchOS)
                .padding([.bottom], 2)
                #endif
        }
        .onChange(of: account.userID) { newValue in
            self.usersFetchedResultsController.fetchRequest = Self.newFetchRequest(userID: newValue)
        }
    }

    @ViewBuilder var sectionRows: some View {
        if let user = usersFetchedResultsController.fetchedObjects.first {
            let displayAccountName = user.sortedUserDetails?.last?.displayUsername ?? account.displayUserID ?? account.objectID.description

            NavigationLink(
                tag: .profile(account),
                selection: $navigationItemSelection
            ) {
                UserView(userID: user.id!)
                    .environment(\.account, account)
            } label: {
                Label("Account", systemImage: "person")
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Account for \(displayAccountName)")
            .accessibilityIdentifier("\(displayAccountName):Account")
            .accessibilityAddTraits(.isButton)

            NavigationLink(
                tag: .followings(account),
                selection: $navigationItemSelection
            ) {
                UsersDiffList("Followings History", user: user, diffKeyPath: \.followingUserIDs)
                    .environment(\.account, account)
            } label: {
                Label("Followings History", systemImage: "person.2")
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Followings History for \(displayAccountName)")
            .accessibilityIdentifier("\(displayAccountName):FollowingsHistory")
            .accessibilityAddTraits(.isButton)

            NavigationLink(
                tag: .followers(account),
                selection: $navigationItemSelection
            ) {
                UsersDiffList("Followers History", user: user, diffKeyPath: \.followerUserIDs)
                    .environment(\.account, account)
            } label: {
                Label("Followers History", systemImage: "person.2")
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Followers History for \(displayAccountName)")
            .accessibilityIdentifier("\(displayAccountName):FollowersHistory")
            .accessibilityAddTraits(.isButton)

            if account.preferences.fetchBlockingUsers {
                NavigationLink(
                    tag: .blockings(account),
                    selection: $navigationItemSelection
                ) {
                    UsersDiffList("Blocks History", user: user, diffKeyPath: \.blockingUserIDs)
                        .environment(\.account, account)
                } label: {
                    Label("Blocks History", systemImage: "nosign")
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Blocks History for \(displayAccountName)")
                .accessibilityIdentifier("\(displayAccountName):BlocksHistory")
                .accessibilityAddTraits(.isButton)
            }

            if account.preferences.fetchMutingUsers {
                NavigationLink(
                    tag: .mutings(account),
                    selection: $navigationItemSelection
                ) {
                    UsersDiffList("Mutes History", user: user, diffKeyPath: \.mutingUserIDs)
                        .environment(\.account, account)
                } label: {
                    Label("Mutes History", systemImage: "speaker.slash")
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Mutes History for \(displayAccountName)")
                .accessibilityIdentifier("\(displayAccountName):MutesHistory")
                .accessibilityAddTraits(.isButton)
            }
        }
    }

    static private func newFetchRequest(userID: String?) -> NSFetchRequest<User> {
        let fetchRequest = User.fetchRequest()
        if let userID = userID {
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
    }

    init(account: Account, navigationItemSelection: Binding<AppSidebarNavigationItem?>) {
        self.account = account
        self._navigationItemSelection = navigationItemSelection

        self._usersFetchedResultsController = StateObject(
            wrappedValue: FetchedResultsController(
                fetchRequest: Self.newFetchRequest(userID: account.userID),
                managedObjectContext: TweetNestApp.session.persistentContainer.viewContext
            )
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

