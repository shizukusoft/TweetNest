//
//  TweetNestApp.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/02/23.
//

import SwiftUI
import TweetNestKit
import UserNotifications
import UnifiedLogging

#if os(iOS)
typealias ApplicationDelegateAdaptor = UIApplicationDelegateAdaptor
#elseif os(macOS)
typealias ApplicationDelegateAdaptor = NSApplicationDelegateAdaptor
#endif

@main
struct TweetNestApp: App {
    @ApplicationDelegateAdaptor(TweetNestAppDelegate.self) var delegate
    @Environment(\.scenePhase) private var scenePhase

    @State var error: Error?
    @State var showErrorAlert: Bool = false

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, Session.shared.container.viewContext)
                .alert(Text("Error"), isPresented: $showErrorAlert, presenting: error) {
                    Text($0.localizedDescription)
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
                .onChange(of: scenePhase) { phase in
                    switch phase {
                    case .active, .inactive:
                        break
                    case .background:
                        do {
                            try Session.shared.scheduleAppRefresh()
                        } catch {
                            Logger().error("Error occured while schedule refresh: \(String(describing: error))")
                        }
                    @unknown default:
                        break
                    }
                }
        }
    }
}
