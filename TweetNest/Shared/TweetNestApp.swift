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
        Group {
            WindowGroup {
                MainView()
                    .environment(\.session, session)
                    .environment(\.managedObjectContext, session.persistentContainer.viewContext)
            }
            #if os(iOS) || os(macOS)
            .commands {
                SidebarCommands()
            }
            #endif

            #if os(macOS)
            Settings {
                SettingsMainView()
                    .environment(\.session, session)
                    .environment(\.managedObjectContext, session.persistentContainer.viewContext)
            }
            #endif
        }
        .onChange(of: scenePhase) { phase in
            Task {
                do {
                    switch phase {
                    case .active:
                        try await BackgroundTaskScheduler.shared.scheduleBackgroundTasks(for: .active)
                    case .inactive:
                        try await BackgroundTaskScheduler.shared.scheduleBackgroundTasks(for: .inactive)
                    case .background:
                        try await BackgroundTaskScheduler.shared.scheduleBackgroundTasks(for: .background)
                    @unknown default:
                        break
                    }

                } catch {
                    Logger().error("Error occurred while schedule refresh: \(String(reflecting: error), privacy: .public)")
                }
            }
        }
    }
}
