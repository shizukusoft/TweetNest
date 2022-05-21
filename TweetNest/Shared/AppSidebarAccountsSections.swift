//
//  AppSidebarAccountsSections.swift
//  TweetNestKit
//
//  Created by 강재홍 on 2022/04/21.
//

import SwiftUI
import TweetNestKit

struct AppSidebarAccountsSections: View {
    @Binding var navigationItemSelection: AppSidebarNavigationItem?

    @StateObject private var accountsFetchedResultsController = FetchedResultsController<ManagedAccount>(
        sortDescriptors: [
            SortDescriptor(\.preferringSortOrder, order: .forward),
            SortDescriptor(\.creationDate, order: .reverse),
        ],
        managedObjectContext: TweetNestApp.session.persistentContainer.viewContext,
        cacheName: "Accounts"
    )

    var body: some View {
        let accounts = accountsFetchedResultsController.fetchedObjects

        ForEach(accounts) { account in
            Section(account: account, navigationItemSelection: $navigationItemSelection)
        }
        .animation(.default, value: accounts)
    }
}

#if DEBUG
struct AppSidebarAccountsSections_Previews: PreviewProvider {

    static var previews: some View {
        NavigationView {
            List {
                AppSidebarAccountsSections(navigationItemSelection: .constant(nil))
            }
            #if os(iOS) || os(macOS)
            .listStyle(.sidebar)
            #endif
            #if os(iOS) || os(watchOS)
            .navigationBarHidden(true)
            #endif
        }
    }
}
#endif
