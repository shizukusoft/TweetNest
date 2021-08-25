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

    @State private var showSettings: Bool = false

    @State private var webAuthenticationSession: ASWebAuthenticationSession? = nil
    @State private var isAddingAccount: Bool = false

    @State private var isRefreshing: Bool = false

    @State private var showErrorAlert: Bool = false
    @State private var error: TweetNestError? = nil

    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\.preferringSortOrder, order: .forward),
            SortDescriptor(\.creationDate, order: .reverse),
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
                            Text(verbatim: account.user?.displayUsername ?? account.description),
                            icon: {
                                ProfileImage(userDetail: account.user?.sortedUserDetails?.last)
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
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        showSettings.toggle()
                    } label: {
                        Label {
                            Text("Settings")
                        } icon: {
                            Image(systemName: "gearshape")
                        }
                    }
                }

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
            .alert(isPresented: $showErrorAlert, error: error)
            .sheet(isPresented: $showSettings) {
                NavigationView {
                    SettingsMainView()
                        .toolbar {
                            ToolbarItemGroup(placement: .cancellationAction) {
                                Button(Text("Cancel"), role: .cancel) {
                                    showSettings.toggle()
                                }
                            }
                        }
                        .navigationTitle(Text("Settings"))
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
                defer {
                    withAnimation {
                        webAuthenticationSession = nil
                        isAddingAccount = false
                    }
                }
                
                try await Session.shared.authorizeNewAccount { webAuthenticationSession in
                    self.webAuthenticationSession = webAuthenticationSession
                }
            } catch ASWebAuthenticationSessionError.canceledLogin {
                Logger().error("Error occurred: \(String(reflecting: ASWebAuthenticationSessionError.canceledLogin), privacy: .public)")
            } catch {
                withAnimation {
                    Logger().error("Error occurred: \(String(reflecting: error), privacy: .public)")
                    self.error = TweetNestError(error)
                    showErrorAlert = true
                }
            }
        }
    }

    @Sendable
    private func refresh() async {
        #if os(iOS)
        let backgroundTaskIdentifier = await withUnsafeCurrentTask { task in
            Task {
                await UIApplication.shared.beginBackgroundTask {
                    task?.cancel()
                }
            }
        }.value

        defer {
            Task {
                await UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
            }
        }
        #endif
        
        guard isRefreshing == false else {
            return
        }

        isRefreshing = true
        defer {
            isRefreshing = false
        }

        do {
            let hasChanges = try await Session.shared.updateAccounts()
            
            for hasChanges in hasChanges {
                _ = try hasChanges.1.get()
            }
        } catch {
            Logger().error("Error occurred: \(String(reflecting: error), privacy: .public)")
            self.error = TweetNestError(error)
            showErrorAlert = true
        }
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
