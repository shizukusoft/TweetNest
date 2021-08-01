//
//  AccountsSection.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/02/24.
//

import SwiftUI
import CoreData
import TweetNestKit
import AuthenticationServices

struct AccountsSection: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Account.creationDate, ascending: true)],
        animation: .default)
    private var accounts: FetchedResults<Account>

    @Binding var navigationItemSelection: AppSidebarNavigation.NavigationItem?

    var body: some View {
        Section {
            ForEach(accounts) { account in
                AccountsSectionRow(account: account, navigationItemSelection: $navigationItemSelection)
            }
            .onDelete(perform: deleteAccounts)
        } header: {
            Text("Accounts")
        }
        #if os(macOS)
        .collapsible(false)
        #endif
    }

    private func deleteAccounts(offsets: IndexSet) {
        withAnimation {
            offsets.map { accounts[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

#if DEBUG
struct AccountsListView_Previews: PreviewProvider {
    static var previews: some View {
        AccountsSection(navigationItemSelection: .constant(nil))
    }
}
#endif
