//
//  AppSidebarNavigation.swift
//  AppSidebarNavigation
//
//  Created by Jaehong Kang on 2021/07/31.
//

import SwiftUI
import AuthenticationServices
import TweetNestKit
import UnifiedLogging

struct AppSidebarNavigation: View {
    enum NavigationItem: Hashable {
        case profile(Account)
        case followings(Account)
        case followers(Account)
        case blockings(Account)
    }

    @State private var navigationItemSelection: NavigationItem? = nil

    @State private var showAccountsEditor: Bool = false

    @State private var webAuthenticationSession: ASWebAuthenticationSession? = nil
    @State private var isAddingAccount: Bool = false

    @State private var isRefreshing: Bool = false

    @State private var showErrorAlert: Bool = false
    @State private var error: Error? = nil

    @FetchRequest(
        sortDescriptors: [
            SortDescriptor.init(\.sortOrder, order: .forward),
            SortDescriptor.init(\.creationDate, order: .reverse),
        ],
        animation: .default)
    private var accounts: FetchedResults<Account>

    @Environment(\.refresh) private var refreshAction

    var body: some View {
        NavigationView {
            List {
                ForEach(accounts) { account in
                    Section(
                        Label(
                            Text(verbatim: account.user?.sortedUserDatas?.last?.username.flatMap({"@\($0)"}) ?? "#\(account.id.formatted())"),
                            icon: {
                                ProfileImage(userData: account.user?.sortedUserDatas?.last)
                                .frame(width: 24, height: 24)
                            }
                        )
                    )
                    {
                        AppSidebarAccountRows(account: account, navigationItemSelection: $navigationItemSelection)
                    }
                }
            }
            .listStyle(.sidebar)
            .refreshable(action: refresh)
            .navigationTitle(Text("TweetNest"))
            .toolbar {
                #if os(iOS)
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(Text("Edit")) {
                        showAccountsEditor.toggle()
                    }
                }
                #endif

                ToolbarItemGroup(placement: .primaryAction) {
                    Button(action: addAccount) {
                        ZStack {
                            Label(Text("Add Account"), systemImage: "plus")

                            if let webAuthenticationSession = webAuthenticationSession {
                                WebAuthenticationView(webAuthenticationSession: webAuthenticationSession)
                                    .zIndex(1.0)
                            }
                        }
                    }
                    .disabled(isAddingAccount)

                    #if !os(iOS)
                    Button(Label(Text("Refresh"), systemImage: "arrow.clockwise")) {
                        if let refresh = refreshAction {
                            Task {
                                refresh
                            }
                        }
                    }
                    .disabled(isRefreshing)
                    #endif
                }
            }
            .accessibilityAction(named: "Refresh") {
                if let refresh = refreshAction {
                    Task {
                        refresh
                    }
                }
            }
            .alertError(isPresented: $showErrorAlert, error: $error)
            .sheet(isPresented: $showAccountsEditor) {
                NavigationView {
                    AccountsEditorView()
                        .toolbar {
                            ToolbarItemGroup(placement: .cancellationAction) {
                                Button(Text("Cancel"), role: .cancel) {
                                    showAccountsEditor.toggle()
                                }
                            }
                        }
                }
            }
        }
    }

    private func addAccount() {
        withAnimation {
            isAddingAccount = true
        }

        Task {
            do {
                try await Session.shared.authorizeNewAccount { webAuthenticationSession in
                    self.webAuthenticationSession = webAuthenticationSession
                }

                webAuthenticationSession = nil

                withAnimation {
                    isAddingAccount = false
                }
            } catch {
                withAnimation {
                    webAuthenticationSession = nil
                    Logger().error("Error occurred: \(String(reflecting: error), privacy: .public)")
                    self.error = error
                    showErrorAlert = true
                    isAddingAccount = false
                }
            }
        }
    }

    @Sendable
    private func refresh() async {
        guard isRefreshing == false else {
            return
        }

        isRefreshing = true

        let task = Task.detached {
            try await Session.shared.updateAccounts()
        }

        #if os(iOS)
        let backgroundTaskIdentifier = await UIApplication.shared.beginBackgroundTask {
            task.cancel()
        }
        #endif

        do {
            _ = try await task.value

            isRefreshing = false
        } catch {
            Logger().error("Error occurred: \(String(reflecting: error), privacy: .public)")
            self.error = error
            showErrorAlert = true
            isRefreshing = false
        }

        #if os(iOS)
        await UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
        #endif
    }
}

#if DEBUG
struct AppSidebarNavigation_Previews: PreviewProvider {
    static var previews: some View {
        AppSidebarNavigation()
            .environment(\.managedObjectContext, Session.preview.container.viewContext)
    }
}
#endif
