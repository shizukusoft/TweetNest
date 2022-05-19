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
    #if DEBUG
    static nonisolated var isPreview: Bool {
        CommandLine.arguments.contains("-com.tweetnest.TweetNest.Preview") || ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
    #endif

    static nonisolated var session: Session {
        #if DEBUG
        if isPreview {
            return Session.preview
        } else {
            return Session.shared
        }
        #else
        return Session.shared
        #endif
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
                Self.session.persistentContainer.usersSpotlightDelegate?.startSpotlightIndexing()
                #endif
            case .background:
                Self.session.pauseBackgroundTaskTimers()
                #if (canImport(BackgroundTasks) && !os(macOS)) || canImport(WatchKit)
                Task {
                    await BackgroundTaskScheduler.shared.scheduleBackgroundTasks()
                }
                #endif
                #if canImport(CoreSpotlight)
                Self.session.persistentContainer.usersSpotlightDelegate?.stopSpotlightIndexing()
                #endif
            @unknown default:
                break
            }
        }
    }
}
