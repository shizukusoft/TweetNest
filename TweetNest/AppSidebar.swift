//
//  AppSidebar.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2022/08/28.
//

import SwiftUI
import TweetNestKit
import BackgroundTask
import UnifiedLogging

struct AppSidebar: View {
    let isPersistentContainerLoaded: Bool
    @Binding var sidebarNavigationItemSelection: AppSidebarNavigationItem?

    #if os(iOS)
    @State private var showSettings: Bool = false
    #endif

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
        TwitterAuthenticationButton {
            Label("Add Account", systemImage: "plus")
        }
        .disabled(isPersistentContainerLoaded == false)
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

    @StateObject private var accountsFetchedResultsController = FetchedResultsController<ManagedAccount>(
        sortDescriptors: [
            SortDescriptor(\.preferringSortOrder, order: .forward),
            SortDescriptor(\.creationDate, order: .reverse),
        ],
        managedObjectContext: TweetNestApp.session.persistentContainer.viewContext,
        cacheName: "Accounts"
    )

    @ViewBuilder var list: some View {
        let accounts = accountsFetchedResultsController.fetchedObjects

        #if !os(watchOS)
        List(accounts, selection: $sidebarNavigationItemSelection) { account in
            AppSidebarAccountSection(
                account: account, sidebarNavigationItemSelection: $sidebarNavigationItemSelection)
        }
        #else
        List {
            ForEach(accounts) { account in
                AppSidebarAccountSection(
                    account: account, sidebarNavigationItemSelection: $sidebarNavigationItemSelection)
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
                AppStatusView(isPersistentContainerLoaded: isPersistentContainerLoaded)
            }
            #endif
        }
        #endif
    }

    var body: some View {
        list
            #if os(macOS)
            .frame(minWidth: 182)
            #endif
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
                #endif

                #if os(iOS)
                ToolbarItemGroup(placement: .status) {
                    AppStatusView(isPersistentContainerLoaded: isPersistentContainerLoaded)
                }
                #endif
            }
            #if os(macOS)
            .safeAreaInset(
                edge: .bottom,
                alignment: .center,
                spacing: 0
            ) {
                AppStatusView(isPersistentContainerLoaded: isPersistentContainerLoaded)
            }
            #endif
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

struct AppSidebar_Previews: PreviewProvider {
    static var previews: some View {
        AppSidebar(
            isPersistentContainerLoaded: true,
            sidebarNavigationItemSelection: .constant(nil)
        )
    }
}
