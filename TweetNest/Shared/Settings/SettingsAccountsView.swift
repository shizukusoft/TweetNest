//
//  SettingsAccountsView.swift
//  SettingsAccountsView
//
//  Created by Jaehong Kang on 2021/09/07.
//

import SwiftUI
import TweetNestKit

struct SettingsAccountsView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\.preferringSortOrder, order: .forward),
            SortDescriptor(\.creationDate, order: .reverse),
        ],
        animation: .default
    )
    private var accounts: FetchedResults<ManagedAccount>

    #if os(macOS)
    var body: some View {
        NavigationView {
            List {
                ForEach(accounts) { account in
                    NavigationLink {
                        SettingsAccountView(account: account)
                    } label: {
                        AccountLabel(account: account)
                    }
                }
                .onDelete(perform: deleteAccounts)
                .onMove(perform: moveAccounts)
            }
        }
        .navigationTitle(Text("Accounts"))
    }
    #else
    var body: some View {
        List {
            ForEach(accounts) { account in
                NavigationLink {
                    SettingsAccountView(account: account)
                } label: {
                    AccountLabel(account: account)
                }
            }
            .onDelete(perform: deleteAccounts)
            .onMove(perform: moveAccounts)
        }
        #if os(iOS)
        .toolbar {
            EditButton()
        }
        #endif
        .navigationTitle(Text("Accounts"))
    }
    #endif

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

    private func moveAccounts(fromOffsets source: IndexSet, toOffset destination: Int) {
        withAnimation {
            var accounts = Array(accounts)
            accounts.move(fromOffsets: source, toOffset: destination)
            accounts.enumerated().forEach {
                $0.element.preferringSortOrder = Int64($0.offset)
            }

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

struct SettingsAccountsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsAccountsView()
    }
}
