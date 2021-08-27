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

struct AppSidebarNavigation: View {
    enum NavigationItem: Hashable {
        case profile(Account)
        case followings(Account)
        case followers(Account)
        case blockings(Account)
    }

    @State private var navigationItemSelection: NavigationItem? = nil
    
    @Environment(\.session) private var session: Session

    @State private var disposables = Set<AnyCancellable>()
    
    @State private var persistentContainerEvents: [PersistentContainer.Event] = []

    #if os(iOS)
    @State private var showSettings: Bool = false
    #endif

    #if os(iOS) || os(macOS)
    @State private var webAuthenticationSession: ASWebAuthenticationSession? = nil
    @State private var isAddingAccount: Bool = false
    #endif

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
    
    @ViewBuilder
    var persistentContainerEventView: some View {
        HStack {
            if let event = persistentContainerEvents.first(where: { $0.endDate == nil }) {
                Spacer()
                HStack(spacing: 8) {
                    ProgressView()
                    
                    Group {
                        switch event.type {
                        case .setup:
                            Text("Starting...")
                        case .import:
                            Text("Importing...")
                        case .export:
                            Text("Exporting...")
                        @unknown default:
                            Text("Syncing...")
                        }
                    }
                    .font(.system(.callout))
                    .foregroundColor(.gray)
                }
                Spacer()
            }
        }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(accounts) { account in
                    Section(
                        Label(
                            Text(verbatim: account.user?.displayUsername ?? account.objectID.description),
                            icon: {
                                ProfileImage(userDetail: account.user?.sortedUserDetails?.last)
                                .frame(width: 24, height: 24)
                            }
                        )
                    ) {
                        AppSidebarAccountRows(account: account, navigationItemSelection: $navigationItemSelection)
                    }
                }
                
                #if os(watchOS)
                persistentContainerEventView
                #endif
            }
            .task {
                await session.$persistentContainerEvents
                    .sink {
                        persistentContainerEvents = $0.lazy
                            .map { $0.value }
                    }
                    .store(in: &disposables)
            }
            #if os(iOS) || os(macOS)
            .listStyle(.sidebar)
            #endif
            .refreshable(action: refresh)
            .navigationTitle(Text("TweetNest"))
            .toolbar {
                #if os(iOS)
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
                #endif

                #if os(iOS) || os(macOS)
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
                #endif
                
                #if os(iOS) || os(macOS)
                ToolbarItemGroup(placement: .status) {
                    persistentContainerEventView
                }
                #endif
            }
            .alert(isPresented: $showErrorAlert, error: error)
            #if os(iOS)
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
            #endif
        }
    }
    
    #if os(iOS) || os(macOS)
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
    #endif

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
            .environment(\.managedObjectContext, Session.preview.persistentContainer.viewContext)
    }
}
#endif
