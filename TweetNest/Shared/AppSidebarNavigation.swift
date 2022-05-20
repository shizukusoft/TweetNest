//
//  AppSidebarNavigation.swift
//  AppSidebarNavigation
//
//  Created by Jaehong Kang on 2021/07/31.
//

import SwiftUI
import AuthenticationServices
import TweetNestKit
import BackgroundTask
import UnifiedLogging

enum AppSidebarNavigationItem: Hashable {
    case profile(ManagedAccount)
    case followings(ManagedAccount)
    case followers(ManagedAccount)
    case blockings(ManagedAccount)
    case mutings(ManagedAccount)
}

struct AppSidebarNavigation: View {
    @Binding var isPersistentContainerLoaded: Bool

    #if os(iOS)
    @State private var showSettings: Bool = false
    #endif

    @State private var navigationItemSelection: AppSidebarNavigationItem?

    @State private var webAuthenticationSession: ASWebAuthenticationSession?
    @State private var isAddingAccount: Bool = false

    @State private var isRefreshing: Bool = false

    @State private var showErrorAlert: Bool = false
    @State private var error: TweetNestError?

    @Environment(\.refresh) private var refreshAction

    @ViewBuilder
    var showSettingsLabel: some View {
        Label {
            Text("Settings")
        } icon: {
            Image(systemName: "gearshape")
        }
    }

    @ViewBuilder
    var addAccountButton: some View {
        Button(action: addAccount) {
            Label("Add Account", systemImage: "plus")
        }
        .disabled(isPersistentContainerLoaded == false || isAddingAccount)
    }

    #if os(macOS) || os(watchOS)
    @ViewBuilder
    var refreshButton: some View {
        Button {
            Task {
                if let refreshAction = refreshAction {
                    await refreshAction()
                } else {
                    await refresh()
                }
            }
        } label: {
            Label("Refresh", systemImage: "arrow.clockwise")
        }
        .disabled(isPersistentContainerLoaded == false || isRefreshing)
    }
    #endif

    var body: some View {
        NavigationView {
            ZStack {
                List {
                    if isPersistentContainerLoaded {
                        AppSidebarAccountsSections(navigationItemSelection: $navigationItemSelection)
                    }

                    #if os(watchOS)
                    Section {
                        addAccountButton
                    }

                    Section {
                        NavigationLink {
                            SettingsMainView()
                        } label: {
                            showSettingsLabel
                        }
                    } footer: {
                        #if os(watchOS)
                        AppStatusView(isPersistentContainerLoaded: isPersistentContainerLoaded)
                        #endif
                    }
                    #endif
                }
                #if os(macOS)
                .frame(minWidth: 182)
                #endif

                if let webAuthenticationSession = webAuthenticationSession {
                    WebAuthenticationView(webAuthenticationSession: webAuthenticationSession)
                        .zIndex(-1)
                }
            }
            #if os(iOS) || os(macOS)
            .listStyle(.sidebar)
            #endif
            .refreshable(action: refresh)
            .navigationTitle(Text(verbatim: "TweetNest"))
            .toolbar {
                #if os(iOS)
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        showSettings.toggle()
                    } label: {
                        showSettingsLabel
                    }
                }
                #endif

                #if os(macOS) || os(watchOS)
                ToolbarItemGroup(placement: .primaryAction) {
                    refreshButton
                        #if os(watchOS)
                        .padding(.bottom)
                        #endif
                }
                #endif

                #if os(macOS) || os(iOS)
                ToolbarItemGroup(placement: .automatic) {
                    addAccountButton
                }

                ToolbarItemGroup(placement: .status) {
                    AppStatusView(isPersistentContainerLoaded: isPersistentContainerLoaded)
                }
                #endif
            }
            .alert(isPresented: $showErrorAlert, error: error)
            #if os(iOS)
            .sheet(isPresented: $showSettings) {
                NavigationView {
                    SettingsMainView()
                        .toolbar {
                            ToolbarItemGroup(placement: .primaryAction) {
                                Button("Done") {
                                    showSettings.toggle()
                                }
                            }
                        }
                }
            }
            #endif
        }
    }

    private func addAccount() {
        withAnimation {
            isAddingAccount = true
        }

        Task {
            defer {
                withAnimation {
                    webAuthenticationSession = nil
                    isAddingAccount = false
                }
            }

            do {
                try await TweetNestApp.session.authorizeNewAccount { webAuthenticationSession in
                    webAuthenticationSession.prefersEphemeralWebBrowserSession = true

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
        guard isRefreshing == false else {
            return
        }

        isRefreshing = true
        defer {
            isRefreshing = false
        }

        do {
            try await withExtendedBackgroundExecution {
                _ = try await TweetNestApp.session.fetchNewData(force: true)
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
        AppSidebarNavigation(isPersistentContainerLoaded: .constant(true))
            .environment(\.managedObjectContext, Session.preview.persistentContainer.viewContext)
    }
}
#endif
