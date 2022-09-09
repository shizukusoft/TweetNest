//
//  AppContentView.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2022/08/28.
//

import SwiftUI
import TweetNestKit

struct AppContentView: View {
    let isPersistentContainerLoaded: Bool
    let sidebarNavigationItemSelection: AppSidebarNavigationItem?

    @Binding var navigationSplitViewVisibility: _NavigationSplitViewVisibility?

    @Environment(\.managedObjectContext) private var managedObjectContext

    var body: some View {
        if isPersistentContainerLoaded {
            switch sidebarNavigationItemSelection {
            case .profile(accountManagedObjectID: let accountManagedObjectID, accountUserID: let accountUserID):
                UserView(userID: accountUserID)
                    .environment(
                        \.account,
                        account(for: accountManagedObjectID)
                    )
            case .followings(accountManagedObjectID: let accountManagedObjectID, accountUserID: let accountUserID):
                UsersDiffList("Followings History", userID: accountUserID, diffKeyPath: \.followingUserIDs)
                    .environment(
                        \.account,
                        account(for: accountManagedObjectID)
                    )
            case .followers(accountManagedObjectID: let accountManagedObjectID, accountUserID: let accountUserID):
                UsersDiffList("Followers History", userID: accountUserID, diffKeyPath: \.followerUserIDs)
                    .environment(
                        \.account,
                        account(for: accountManagedObjectID)
                    )
            case .blockings(accountManagedObjectID: let accountManagedObjectID, accountUserID: let accountUserID):
                UsersDiffList("Blocks History", userID: accountUserID, diffKeyPath: \.blockingUserIDs)
                    .environment(
                        \.account,
                        account(for: accountManagedObjectID)
                    )
            case .mutings(accountManagedObjectID: let accountManagedObjectID, accountUserID: let accountUserID):
                UsersDiffList("Mutes History", userID: accountUserID, diffKeyPath: \.mutingUserIDs)
                    .environment(
                        \.account,
                        account(for: accountManagedObjectID)
                    )
            case .none:
                Rectangle()
                    .foregroundColor(.clear)
                    .onAppear {
                        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                            navigationSplitViewVisibility?.value = .all
                        }
                    }
                    .onDisappear {
                        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                            navigationSplitViewVisibility?.value = .automatic
                        }
                    }
            }
        }
    }

    init(
        isPersistentContainerLoaded: Bool,
        sidebarNavigationItemSelection: AppSidebarNavigationItem?,
        navigationSplitViewVisibility: Binding<_NavigationSplitViewVisibility?> = .constant(nil)
    ) {
        self.isPersistentContainerLoaded = isPersistentContainerLoaded
        self.sidebarNavigationItemSelection = sidebarNavigationItemSelection
        self._navigationSplitViewVisibility = navigationSplitViewVisibility
    }

    func account(for accountManagedObjectID: URL) -> ManagedAccount? {
        managedObjectContext.persistentStoreCoordinator?
            .managedObjectID(forURIRepresentation: accountManagedObjectID)
            .flatMap {
                managedObjectContext.object(with: $0) as? ManagedAccount
            }
    }
}

struct AppContentView_Previews: PreviewProvider {
    static var previews: some View {
        AppContentView(
            isPersistentContainerLoaded: true,
            sidebarNavigationItemSelection: nil
        )
    }
}
