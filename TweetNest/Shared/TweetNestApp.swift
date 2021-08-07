//
//  TweetNestApp.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/02/23.
//

import SwiftUI
import TweetNestKit
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

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, Session.shared.container.viewContext)
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active, .inactive:
                break
            case .background:
                #if os(iOS)
                do {
                    try Session.shared.scheduleUpdateAccountsBackgroundTask()
                } catch {
                    Logger().error("Error occured while schedule refresh: \(String(reflecting: error), privacy: .public)")
                }
                #else
                break
                #endif
            @unknown default:
                break
            }
        }
    }
}
