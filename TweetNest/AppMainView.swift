//
//  AppMainView.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2022/08/28.
//

import SwiftUI
import UserNotifications
import TweetNestKit
import UnifiedLogging

#if canImport(CoreSpotlight)
import CoreSpotlight
#endif

struct AppMainView: View {
    @State private var navigationSplitViewVisibility: _NavigationSplitViewVisibility = {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            return _NavigationSplitViewVisibility(.all)
        } else {
            return _NavigationSplitViewVisibility()
        }
    }()
    @State private var sidebarNavigationItemSelection: AppSidebarNavigationItem?
    @State private var isPersistentContainerLoaded: Bool = false

    @State var error: TweetNestError?
    @State var showErrorAlert: Bool = false

    @State var user: ManagedUser?

    @Environment(\.managedObjectContext) private var viewContext

    @ViewBuilder
    private var sidebar: some View {
        AppSidebar(
            isPersistentContainerLoaded: isPersistentContainerLoaded,
            sidebarNavigationItemSelection: $sidebarNavigationItemSelection
        )
    }

    @ViewBuilder
    private var content: some View {
        AppContentView(
            sidebarNavigationItemSelection: sidebarNavigationItemSelection,
            navigationSplitViewVisibility: Binding($navigationSplitViewVisibility)
        )
    }

    @ViewBuilder
    private var detail: some View {
        AppDetailView()
    }

    @ViewBuilder
    private var navigationView: some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            NavigationSplitView(
                columnVisibility: $navigationSplitViewVisibility.value
            ) {
                sidebar
            } content: {
                content
            } detail: {
                detail
            }
        } else {
            NavigationView {
                sidebar
                content
                detail
            }
        }
    }

    var body: some View {
        navigationView
            .alert(isPresented: $showErrorAlert, error: error)
            .sheet(item: $user) { user in
                NavigationView {
                    Group {
                        if let userID = user.id {
                            UserView(userID: userID)
                        }
                    }
                    .toolbar {
                        ToolbarItemGroup(placement: .cancellationAction) {
                            Button("Cancel", role: .cancel) {
                                self.user = nil
                            }
                        }
                    }
                }
            }
            .task {
                do {
                    try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
                } catch {
                    Logger().error("Error occurred: \(error as NSError, privacy: .public)")
                    self.error = TweetNestError(error)
                    self.showErrorAlert = true
                }
            }
            .onAppear {
                updatePersistentContainerLoadingResult(TweetNestApp.session.persistentContainerLoadingResult)
            }
            .onReceive(TweetNestApp.session.$persistentContainerLoadingResult) { result in
                updatePersistentContainerLoadingResult(result)
            }
            #if canImport(CoreSpotlight)
            .onContinueUserActivity(CSSearchableItemActionType, perform: handleSpotlightUserActivity(_:))
            #endif
    }

    func updatePersistentContainerLoadingResult(_ result: Result<Void, Error>?) {
        guard let result = result else {
            isPersistentContainerLoaded = false
            return
        }

        do {
            try result.get()

            isPersistentContainerLoaded = true
        } catch {
            self.error = TweetNestError(error)
            showErrorAlert = true
        }
    }

    #if canImport(CoreSpotlight)
    func handleSpotlightUserActivity(_ userActivity: NSUserActivity) {
        guard
            let identifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String,
            let uri = URL(string: identifier),
            let objectID = viewContext.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: uri),
            let user = viewContext.object(with: objectID) as? ManagedUser
        else {
            return
        }

        self.user = user
    }
    #endif
}

struct AppMainView_Previews: PreviewProvider {
    static var previews: some View {
        AppMainView()
    }
}
