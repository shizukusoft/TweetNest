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

struct MainView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Account.addedAt, ascending: true)],
        animation: .default)
    private var accounts: FetchedResults<Account>

    @State var requestToken: TwitterKit.OAuth1Authenticator.RequestToken?
    @State var authenticationResult: Result<URL, Swift.Error>?

    var body: some View {
        NavigationView {
            List {
                ForEach(accounts) { item in
                    Text("Item at \(item.addedAt!, formatter: itemFormatter)")
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

            if let requestToken = requestToken, authenticationResult == nil {
                WebAuthenticationView(
                    url: URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")!,
                    callbackURLScheme: "tweet-nest",
                    callbackURLResult: $authenticationResult
                )
                .zIndex(1.0)
            }
        }
    }

    private func addAccount() {
        authenticationResult = nil
        Session.shared.obtainRequestToken { result in
            switch result {
            case .success(let requestToken):
                self.requestToken = requestToken
            case .failure(let error):
                break
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
