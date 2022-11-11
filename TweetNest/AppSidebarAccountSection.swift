//
//  AppSidebarAccountSection.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2022/08/28.
//

import SwiftUI
import CoreData
import TweetNestKit

struct AppSidebarAccountSection: View {
    @ObservedObject var account: ManagedAccount
    @Binding var sidebarNavigationItemSelection: AppSidebarNavigationItem?

    @StateObject private var userDetailsFetchedResultsController: FetchedResultsController<ManagedUserDetail>

    var body: some View {
        Section {
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

    @ViewBuilder private var sectionRows: some View {
        let displayAccountName = userDetailsFetchedResultsController.fetchedObjects.first?.displayUsername ??
            account.userID?.displayUserID ??
            account.objectID.description

        if let accountUserID = account.userID {
            navigationLink(for: .profile(accountManagedObjectID: account.objectID.uriRepresentation(), accountUserID: accountUserID)) {
                Label("Account", systemImage: "person")
            }
            .accessibilityLabel("Account for \(displayAccountName)")
            .accessibilityIdentifier("\(displayAccountName):Account")

            navigationLink(for: .followings(accountManagedObjectID: account.objectID.uriRepresentation(), accountUserID: accountUserID)) {
                Label("Followings History", systemImage: "person.2")
            }
            .accessibilityLabel("Followings History for \(displayAccountName)")
            .accessibilityIdentifier("\(displayAccountName):FollowingsHistory")

            navigationLink(for: .followers(accountManagedObjectID: account.objectID.uriRepresentation(), accountUserID: accountUserID)) {
                Label("Followers History", systemImage: "person.2")
            }
            .accessibilityLabel("Followers History for \(displayAccountName)")
            .accessibilityIdentifier("\(displayAccountName):FollowersHistory")

            if account.preferences.fetchBlockingUsers {
                navigationLink(for: .blockings(accountManagedObjectID: account.objectID.uriRepresentation(), accountUserID: accountUserID)) {
                    Label("Blocks History", systemImage: "nosign")
                }
                .accessibilityLabel("Blocks History for \(displayAccountName)")
                .accessibilityIdentifier("\(displayAccountName):BlocksHistory")
            }

            if account.preferences.fetchMutingUsers {
                navigationLink(for: .mutings(accountManagedObjectID: account.objectID.uriRepresentation(), accountUserID: accountUserID)) {
                    Label("Mutes History", systemImage: "speaker.slash")
                }
                .accessibilityLabel("Mutes History for \(displayAccountName)")
                .accessibilityIdentifier("\(displayAccountName):MutesHistory")
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

    init(account: ManagedAccount, sidebarNavigationItemSelection: Binding<AppSidebarNavigationItem?>) {
        self.account = account
        self._sidebarNavigationItemSelection = sidebarNavigationItemSelection

        self._userDetailsFetchedResultsController = StateObject(
            wrappedValue: FetchedResultsController(
                fetchRequest: Self.newFetchRequest(userID: account.userID),
                managedObjectContext: TweetNestApp.session.persistentContainer.viewContext
            )
        )
    }

    @ViewBuilder
    private func navigationLink(
        for sidebarNavigationItem: AppSidebarNavigationItem,
        @ViewBuilder label: () -> some View
    ) -> some View {
        #if !os(watchOS)
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            NavigationLink(value: sidebarNavigationItem, label: label)
        } else {
            NavigationLink(
                tag: sidebarNavigationItem,
                selection: $sidebarNavigationItemSelection,
                destination: {
                    AppContentView(isPersistentContainerLoaded: true, sidebarNavigationItemSelection: sidebarNavigationItem)
                },
                label: label
            )
        }
        #else
        NavigationLink(
            tag: sidebarNavigationItem,
            selection: $sidebarNavigationItemSelection,
            destination: {
                AppContentView(isPersistentContainerLoaded: true, sidebarNavigationItemSelection: sidebarNavigationItem)
            },
            label: label
        )
        #endif
    }
}

struct AppSidebarAccountSection_Previews: PreviewProvider {
    static var previews: some View {
        AppSidebarAccountSection(account: .preview, sidebarNavigationItemSelection: .constant(nil))
    }
}
