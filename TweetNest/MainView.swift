//
//  MainView.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/02/24.
//

import SwiftUI
import CoreData
import TweetNestKit
import TwitterKit
import AuthenticationServices

struct MainView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Account.creationDate, ascending: true)],
        animation: .default)
    private var accounts: FetchedResults<Account>

    @State var webAuthenticationSession: ASWebAuthenticationSession?
    @State var authorizationResult: Result<Void, Swift.Error>?

    var body: some View {
        ZStack {
            NavigationView {
                List {
                    ForEach(accounts) { item in
                        Text("Item at \(item.creationDate!, formatter: itemFormatter)")
                    }
                    .onDelete(perform: deleteAccounts)
                }
                .navigationBarTitle(Text("Twitter Accounts"))
                .toolbar(content: {
                    #if os(iOS)
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                    }
                    #endif

                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: addAccount) {
                            Label("Add Item", systemImage: "plus")
                        }
                    }
                })
            }

            if let webAuthenticationSession = webAuthenticationSession {
                WebAuthenticationView(webAuthenticationSession: webAuthenticationSession)
                    .zIndex(1.0)
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

//        withAnimation {
//            let newItem = Account(context: viewContext)
//            newItem.addedAt = Date()
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
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

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environment(\.managedObjectContext, Session.preview.container.viewContext)
    }
}
