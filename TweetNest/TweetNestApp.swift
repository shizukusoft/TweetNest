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
    @available(iOS, deprecated: 16.0)
    @available(macOS, deprecated: 13.0)
    @available(watchOS, deprecated: 9.0)
    @available(tvOS, deprecated: 16.0)
    static nonisolated var session: Session {
        SessionEnvironmentKey.defaultValue
    }

    @ApplicationDelegateAdaptor(TweetNestAppDelegate.self) var delegate
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        Group {
            WindowGroup {
                MainView()
                    .environmentObject(delegate)
                    .environment(\.managedObjectContext, Self.session.persistentContainer.viewContext)
                    #if os(macOS) && DEBUG
                    .frame(width: Self.isPreview ? 1440 : nil, height: Self.isPreview ? (900 - 52) : nil)
                    #endif
            }
            #if os(iOS) || os(macOS)
            .commands {
                SidebarCommands()
            }
            #endif

            #if os(macOS)
            Settings {
                SettingsMainView()
                    .environment(\.managedObjectContext, Self.session.persistentContainer.viewContext)
            }
            #endif
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active, .inactive:
                Self.session.resumeBackgroundTaskTimers()
                #if canImport(CoreSpotlight)
                Self.session.persistentContainer.persistentStoreCoordinator.perform {
                    Self.session.persistentContainer.usersSpotlightDelegate?.startSpotlightIndexing()
                }
                #endif
            case .background:
                Self.session.pauseBackgroundTaskTimers()
                #if (canImport(BackgroundTasks) && !os(macOS)) || canImport(WatchKit)
                Task {
                    await BackgroundTaskScheduler.shared.scheduleBackgroundTasks()
                }
                #endif
                #if canImport(CoreSpotlight)
                Self.session.persistentContainer.persistentStoreCoordinator.performAndWait {
                    Self.session.persistentContainer.usersSpotlightDelegate?.stopSpotlightIndexing()
                }
                #endif
            @unknown default:
                break
            }
        }
    }
}
