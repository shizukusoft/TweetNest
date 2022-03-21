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
    static var isPreview: Bool {
        CommandLine.arguments.contains("-com.tweetnest.TweetNest.Preview") || ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
    #endif

    @ApplicationDelegateAdaptor(TweetNestAppDelegate.self) var delegate
    @Environment(\.scenePhase) private var scenePhase

    var session: Session {
        delegate.session
    }

    var body: some Scene {
        Group {
            WindowGroup {
                MainView()
                    .environmentObject(delegate)
                    .environment(\.session, session)
                    .environment(\.managedObjectContext, session.persistentContainer.viewContext)
                    #if os(macOS) && DEBUG
                    .frame(width: Self.isPreview ? 1440 : nil, height: Self.isPreview ? 900 : nil)
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
                    .environment(\.session, session)
                    .environment(\.managedObjectContext, session.persistentContainer.viewContext)
            }
            #elseif os(watchOS)
            WKNotificationScene(controller: NotificationController.self, category: "NewAccountData")
            #endif
        }
        .onChange(of: scenePhase) { phase in
            Task {
                do {
                    switch phase {
                    case .active:
                        try await session.backgroundTaskScheduler.scheduleBackgroundTasks(for: .active)
                    case .inactive:
                        try await session.backgroundTaskScheduler.scheduleBackgroundTasks(for: .inactive)
                    case .background:
                        try await session.backgroundTaskScheduler.scheduleBackgroundTasks(for: .background)
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
