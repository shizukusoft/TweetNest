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
#elseif os(watchOS)
typealias ApplicationDelegateAdaptor = WKExtensionDelegateAdaptor
#endif

@main
struct TweetNestApp: App {
    @ApplicationDelegateAdaptor(TweetNestAppDelegate.self) var delegate
    @Environment(\.scenePhase) private var scenePhase
    
    let session = Session.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, session.persistentContainer.viewContext)
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
                    Logger().error("Error occurred while schedule refresh: \(String(reflecting: error), privacy: .public)")
                }
                #else
                break
                #endif
            @unknown default:
                break
            }
        }
        
        #if os(macOS)
        Settings {
            SettingsMainView()
        }
        #endif
    }
}
