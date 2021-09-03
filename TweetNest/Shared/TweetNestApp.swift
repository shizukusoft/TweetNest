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
    
    var session: Session {
        delegate.session
    }

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.session, session)
                .environment(\.managedObjectContext, session.persistentContainer.viewContext)
        }
        #if (canImport(BackgroundTasks) && !os(macOS)) || canImport(WatchKit)
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active, .inactive:
                break
            case .background:
                Task {
                    do {
                        try await session.scheduleBackgroundRefreshTask()
                        #if canImport(BackgroundTasks) && !os(macOS)
                        try await session.scheduleDataCleansingBackgroundTaskIfNeeded()
                        #endif
                    } catch {
                        Logger().error("Error occurred while schedule refresh: \(String(reflecting: error), privacy: .public)")
                    }
                }
            @unknown default:
                break
            }
        }
        #endif
        
        #if os(macOS)
        Settings {
            SettingsMainView()
        }
        #endif
    }
}
