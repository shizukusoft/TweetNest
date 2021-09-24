//
//  AppSidebarNavigation.swift
//  AppSidebarNavigation
//
//  Created by Jaehong Kang on 2021/07/31.
//

import SwiftUI
import Combine
import AuthenticationServices
import TweetNestKit
import UnifiedLogging

enum AppSidebarNavigationItem: Hashable {
    case profile(Account)
    case followings(Account)
    case followers(Account)
    case blockings(Account)
}

struct AppSidebarNavigation: View {
    @Environment(\.session) private var session: Session

    @State private var disposables = Set<AnyCancellable>()

    @State private var persistentContainerCloudKitEvents: [PersistentContainer.CloudKitEvent] = []
    private var inProgressPersistentContainerCloudKitEvent: PersistentContainer.CloudKitEvent? {
        persistentContainerCloudKitEvents.first { $0.endDate == nil }
    }

    @Binding var isPersistentContainerLoaded: Bool

    #if os(iOS)
    @State private var showSettings: Bool = false
    #endif

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
                        AppSidebarNavigationAccountsRowContent()
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
                        statusView
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
            .onAppear {
                session.persistentContainer.$cloudKitEvents
                    .map { $0.map { $0.value } }
                    .receive(on: DispatchQueue.main)
                    .assign(to: \.persistentContainerCloudKitEvents, on: self)
                    .store(in: &disposables)
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
                    statusView
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

    @ViewBuilder
    var statusView: some View {
        if isPersistentContainerLoaded == false {
            HStack(spacing: 4) {
                #if !os(watchOS)
                ProgressView()
                #endif

                Text("Loading…")
                    #if !os(watchOS)
                    .font(.system(.callout))
                    .foregroundColor(.secondary)
                    #endif
                    #if os(iOS)
                    .fixedSize()
                    #endif
            }
        } else if let inProgressPersistentContainerCloudKitEvent = inProgressPersistentContainerCloudKitEvent {
            HStack(spacing: 4) {
                #if !os(watchOS)
                ProgressView()
                #endif

                Group {
                    switch inProgressPersistentContainerCloudKitEvent.type {
                    case .setup:
                        Text("Preparing to Sync…")
                    case .import, .export, .unknown:
                        Text("Syncing…")
                    }
                }
                #if !os(watchOS)
                .font(.system(.callout))
                .foregroundColor(.secondary)
                #endif
                #if os(iOS)
                .fixedSize()
                #endif
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

                try await session.authorizeNewAccount { webAuthenticationSession in
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
        await withExtendedBackgroundExecution {
            guard isRefreshing == false else {
                return
            }

            isRefreshing = true
            defer {
                isRefreshing = false
            }

            do {
                let hasChanges = try await session.updateAllAccounts()
                try await session.cleansingAllData()

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
}

#if DEBUG
struct AppSidebarNavigation_Previews: PreviewProvider {
    static var previews: some View {
        AppSidebarNavigation(isPersistentContainerLoaded: .constant(true))
            .environment(\.session, Session.preview)
            .environment(\.managedObjectContext, Session.preview.persistentContainer.viewContext)
    }
}
#endif
