//
//  MainView.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/02/24.
//

import SwiftUI
import TweetNestKit
import UserNotifications

#if canImport(CoreSpotlight)
import CoreSpotlight
#endif

struct MainView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State var error: TweetNestError?
    @State var showErrorAlert: Bool = false

    @State var user: User?

    var body: some View {
        AppSidebarNavigation()
            .alert(isPresented: $showErrorAlert, error: error)
            .sheet(item: $user) { user in
                NavigationView {
                    UserView(user: user)
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
                    self.error = TweetNestError(error)
                    self.showErrorAlert = true
                }
            }
            #if canImport(CoreSpotlight)
            .onContinueUserActivity(CSSearchableItemActionType, perform: handleSpotlightUserActivity(_:))
            #endif
    }

    #if canImport(CoreSpotlight)
    func handleSpotlightUserActivity(_ userActivity: NSUserActivity) {
        guard
            let identifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String,
            let uri = URL(string: identifier),
            let objectID = viewContext.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: uri),
            let user = viewContext.object(with: objectID) as? User
        else {
            return
        }

        self.user = user
    }
    #endif
}

#if DEBUG
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environment(\.managedObjectContext, Session.preview.persistentContainer.viewContext)
    }
}
#endif
