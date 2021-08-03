//
//  TweetNestApp.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/02/23.
//

import SwiftUI
import TweetNestKit
import UserNotifications

#if os(iOS)
typealias ApplicationDelegateAdaptor = UIApplicationDelegateAdaptor
#elseif os(macOS)
typealias ApplicationDelegateAdaptor = NSApplicationDelegateAdaptor
#endif

@main
struct TweetNestApp: App {
    @ApplicationDelegateAdaptor(TweetNestAppDelegate.self) var delegate

    @State var error: Error?
    @State var showErrorAlert: Bool = false

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, Session.shared.container.viewContext)
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
                .alert(Text("Error"), isPresented: $showErrorAlert, presenting: error) {
                    Text($0.localizedDescription)
                }
        }
    }
}
