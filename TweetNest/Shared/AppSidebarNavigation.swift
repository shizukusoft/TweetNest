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
    
    @State private var persistentContainerCloudKitEvents: [PersistentContainer.CloudKitEvent] = []
    private var inProgressPersistentContainerCloudKitEvent: PersistentContainer.CloudKitEvent? {
        persistentContainerCloudKitEvents.first { $0.endDate == nil }
    }
    
    @State private var something: String? = nil

    #if os(iOS)
    @State private var showSettings: Bool = false
    #endif

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
    
    @ViewBuilder
    var showSettingsLabel: some View {
        Label {
            Text("Settings")
        } icon: {
            Image(systemName: "gearshape")
        }
        #if os(watchOS)
        .labelStyle(TweetNestWatchLabelStyle(iconSize: 32))
        #endif
    }
    
    @ViewBuilder
    var addAccountButton: some View {
        Button(action: addAccount) {
            Label(Text("Add Account"), systemImage: "plus")
        }
        .disabled(isAddingAccount)
    }

    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(accounts) { account in
                        Section {
                            AppSidebarAccountRows(account: account, navigationItemSelection: $navigationItemSelection)
                        } header: {
                            Label {
                                Text(verbatim: account.user?.displayUsername ?? account.objectID.description)
                                    #if os(watchOS)
                                    .padding([.top], 4)
                                    .padding([.bottom], 2)
                                    #endif
                            } icon: {
                                ProfileImage(userDetail: account.user?.sortedUserDetails?.last)
                                    #if os(watchOS)
                                    .frame(width: 16, height: 16)
                                    #else
                                    .frame(width: 24, height: 24)
                                    #endif
                            }
                        }
                    }
                    
                    #if os(watchOS)
                    Section {
                        NavigationLink {
                            SettingsMainView()
                        } label: {
                            showSettingsLabel
                        }
                    }
                    #endif
                }
                
                if let webAuthenticationSession = webAuthenticationSession {
                    WebAuthenticationView(webAuthenticationSession: webAuthenticationSession)
                        .zIndex(-1)
                }
            }
            .task {
                await session.$persistentContainerCloudKitEvents
                    .map { $0.map { $0.value } }
                    .receive(on: DispatchQueue.main)
                    .assign(to: \.persistentContainerCloudKitEvents, on: self)
                    .store(in: &disposables)
            }
            .onChange(of: persistentContainerCloudKitEvents) {
                debugPrint($0)
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
                        showSettingsLabel
                    }
                }
                #endif
                
                ToolbarItemGroup(placement: .primaryAction) {
                    #if os(watchOS)
                    if let inProgressPersistentContainerCloudKitEvent = inProgressPersistentContainerCloudKitEvent {
                        VStack {
                            persistentContainerCloudKitEventView(for: inProgressPersistentContainerCloudKitEvent)
                            addAccountButton
                        }
                    } else {
                        addAccountButton
                    }
                    #else
                    addAccountButton
                    #endif
                }
                
                #if os(macOS)
                ToolbarItemGroup(placement: .automatic) {
                    Button(Label(Text("Refresh"), systemImage: "arrow.clockwise")) {
                        if let refresh = refreshAction {
                            Task {
                                refresh
                            }
                        }
                    }
                    .disabled(isRefreshing)
                }
                #endif
                
                #if os(macOS) || os(iOS)
                ToolbarItemGroup(placement: .status) {
                    if let inProgressPersistentContainerCloudKitEvent = inProgressPersistentContainerCloudKitEvent {
                        persistentContainerCloudKitEventView(for: inProgressPersistentContainerCloudKitEvent)
                    }
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
                }
            }
            #endif
        }
    }

    @ViewBuilder
    func persistentContainerCloudKitEventView(for event: PersistentContainer.CloudKitEvent) -> some View {
        HStack(spacing: 4) {
            ProgressView()
                #if os(watchOS)
                .frame(width: 29.5, height: 29.5, alignment: .center)
                #endif
            
            Group {
                switch event.type {
                case .setup:
                    Text("Preparing...")
                case .import:
                    Text("Importing...")
                case .export:
                    Text("Exporting...")
                case .unknown:
                    Text("Syncing...")
                }
            }
            .font(.system(.callout))
            .fixedSize()
            .foregroundColor(.gray)
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
            let hasChanges = try await session.updateAccounts()
            
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
            .environment(\.session, Session.preview)
            .environment(\.managedObjectContext, Session.preview.persistentContainer.viewContext)
    }
}
#endif
