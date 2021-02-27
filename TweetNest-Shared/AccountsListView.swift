//
//  AccountsListView.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/02/24.
//

import SwiftUI
import CoreData
import TweetNestKit
import AuthenticationServices

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct AccountsListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Account.creationDate, ascending: true)],
        animation: .default)
    private var accounts: FetchedResults<Account>

    @State var webAuthenticationSession: ASWebAuthenticationSession?
    @State var authorizationResult: Result<Void, Swift.Error>?

    @Binding var selectedAccount: Account?

    var body: some View {
        ZStack {
            List {
                ForEach(accounts) { account in
                    NavigationLink(
                        account.user?.userDatas.last?.username ?? account.user?.id.flatMap { "#" + $0 } ?? itemFormatter.string(from: account.creationDate!),
                        destination: AccountView(account: account),
                        tag: account,
                        selection: $selectedAccount)
                }
                .onDelete(perform: deleteAccounts)
            }

            if let webAuthenticationSession = webAuthenticationSession {
                WebAuthenticationView(webAuthenticationSession: webAuthenticationSession)
                    .zIndex(1.0)
            }
        }
        .navigationTitle(Text("Twitter Accounts"))
        .toolbar {
            #if os(iOS)
            EditButton()
            #endif

            Button(action: addAccount) {
                Label("Add Account", systemImage: "plus")
            }
        }
    }

    private func addAccount() {
        authorizationResult = nil
        Session.shared.authorizeNewAccount { webAuthenticationSession in
            DispatchQueue.main.async {
                self.webAuthenticationSession = webAuthenticationSession
            }
        } resultHandler: { (result) in
            DispatchQueue.main.async {
                self.authorizationResult = result
                self.webAuthenticationSession = nil
            }
        }
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

struct AccountsListView_Previews: PreviewProvider {
    static var previews: some View {
        AccountsListView(selectedAccount: .constant(nil))
    }
}
