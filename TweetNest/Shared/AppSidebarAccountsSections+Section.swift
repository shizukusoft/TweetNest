//
//  AppSidebarAccountsSection.swift
//  AppSidebarAccountsSection
//
//  Created by Jaehong Kang on 2021/08/05.
//

import SwiftUI
import CoreData
import TweetNestKit

extension AppSidebarAccountsSections {
    struct Section: View {
        @ObservedObject var account: ManagedAccount
        @Binding var navigationItemSelection: AppSidebarNavigationItem?

        @StateObject private var userDetailsFetchedResultsController: FetchedResultsController<ManagedUserDetail>

        var body: some View {
            SwiftUI.Section {
                sectionRows
            } header: {
                UserDetailLabel(userDetail: userDetailsFetchedResultsController.fetchedObjects.first, account: account)
                    #if os(watchOS)
                    .labelStyle(.userDetailLabelStyle(iconWidth: 16, iconHeight: 16))
                    .padding([.bottom], 2)
                    #elseif os (macOS)
                    .labelStyle(.userDetailLabelStyle(iconWidth: 18, iconHeight: 18))
                    #else
                    .labelStyle(.userDetailLabelStyle(iconWidth: 24, iconHeight: 24))
                    #endif
            }
            .onChange(of: account.userID) { newValue in
                self.userDetailsFetchedResultsController.fetchRequest = Self.newFetchRequest(userID: newValue)
            }
        }

        @ViewBuilder var sectionRows: some View {
            let displayAccountName = userDetailsFetchedResultsController.fetchedObjects.first?.displayUsername ??
                account.userID?.displayUserID ??
                account.objectID.description

            if let userID = account.userID {
                NavigationLink(
                    tag: .profile(account),
                    selection: $navigationItemSelection
                ) {
                    UserView(userID: userID)
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
                    UsersDiffList("Followings History", userID: userID, diffKeyPath: \.followingUserIDs)
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
                    UsersDiffList("Followers History", userID: userID, diffKeyPath: \.followerUserIDs)
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
                        UsersDiffList("Blocks History", userID: userID, diffKeyPath: \.blockingUserIDs)
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
                        UsersDiffList("Mutes History", userID: userID, diffKeyPath: \.mutingUserIDs)
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

        static private func newFetchRequest(userID: String?) -> NSFetchRequest<ManagedUserDetail> {
            let fetchRequest = ManagedUserDetail.fetchRequest()
            if let userID = userID {
                fetchRequest.predicate = NSPredicate(format: "userID == %@", userID)
            } else {
                fetchRequest.predicate = NSPredicate(value: false)
            }
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(keyPath: \ManagedUserDetail.creationDate, ascending: false)
            ]
            fetchRequest.returnsObjectsAsFaults = false
            fetchRequest.propertiesToFetch = ["username", "profileImageURL"]
            fetchRequest.fetchLimit = 1

            return fetchRequest
        }

        init(account: ManagedAccount, navigationItemSelection: Binding<AppSidebarNavigationItem?>) {
            self.account = account
            self._navigationItemSelection = navigationItemSelection

            self._userDetailsFetchedResultsController = StateObject(
                wrappedValue: FetchedResultsController(
                    fetchRequest: Self.newFetchRequest(userID: account.userID),
                    managedObjectContext: TweetNestApp.session.persistentContainer.viewContext
                )
            )
        }
    }
}

// #if DEBUG
// struct AppSidebarAccountRows_Previews: PreviewProvider {
//    static var previews: some View {
//        AppSidebarAccountRows()
//    }
// }
// #endif
