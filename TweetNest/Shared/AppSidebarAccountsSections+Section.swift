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
        @ObservedObject var account: Account
        @Binding var navigationItemSelection: AppSidebarNavigationItem?

        @StateObject private var userDetailsFetchedResultsController: FetchedResultsController<UserDetail>

        var body: some View {
            SwiftUI.Section {
                sectionRows
            } header: {
                UserDetailLabel(userDetail: userDetailsFetchedResultsController.fetchedObjects.first, account: account)
                    #if os(watchOS)
                    .padding([.bottom], 2)
                    #endif
            }
            .onChange(of: account.userID) { newValue in
                self.userDetailsFetchedResultsController.fetchRequest = Self.newFetchRequest(userID: newValue)
            }
        }

        @ViewBuilder var sectionRows: some View {
            if
                let latestUserDetail = userDetailsFetchedResultsController.fetchedObjects.first,
                let user = latestUserDetail.user
            {
                let displayAccountName = latestUserDetail.displayUsername ?? account.userID?.displayUserID ?? account.objectID.description

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

        static private func newFetchRequest(userID: String?) -> NSFetchRequest<UserDetail> {
            let fetchRequest = UserDetail.fetchRequest()
            if let userID = userID {
                fetchRequest.predicate = NSPredicate(format: "user.id == %@", userID)
            } else {
                fetchRequest.predicate = NSPredicate(value: false)
            }
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(keyPath: \UserDetail.user?.modificationDate, ascending: false),
                NSSortDescriptor(keyPath: \UserDetail.user?.creationDate, ascending: false),
                NSSortDescriptor(keyPath: \UserDetail.creationDate, ascending: false)
            ]
            fetchRequest.returnsObjectsAsFaults = false
            fetchRequest.relationshipKeyPathsForPrefetching = ["user"]
            fetchRequest.propertiesToFetch = ["username", "profileImageURL"]
            fetchRequest.fetchLimit = 1

            return fetchRequest
        }

        init(account: Account, navigationItemSelection: Binding<AppSidebarNavigationItem?>) {
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

//#if DEBUG
//struct AppSidebarAccountRows_Previews: PreviewProvider {
//    static var previews: some View {
//        AppSidebarAccountRows()
//    }
//}
//#endif

