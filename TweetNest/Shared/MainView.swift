//
//  MainView.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/02/24.
//

import SwiftUI
import TweetNestKit
import UserNotifications
import CoreSpotlight

struct MainView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State var error: Error?
    @State var showErrorAlert: Bool = false

    @State var user: User? = nil

    var body: some View {
        AppSidebarNavigation()
            .alert(Text("Error"), isPresented: $showErrorAlert, presenting: error) {
                Text($0.localizedDescription)
            }
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
            .onAppear {
                Task {
                    do {
                        try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
                    } catch {
                        self.error = error
                        self.showErrorAlert = true
                    }
                }
            }
            .onContinueUserActivity(CSSearchableItemActionType, perform: handleSpotlightUserActivity(_:))
    }

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
}

#if DEBUG
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environment(\.managedObjectContext, Session.preview.container.viewContext)
    }
}
#endif
