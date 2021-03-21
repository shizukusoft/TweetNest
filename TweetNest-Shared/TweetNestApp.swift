//
//  TweetNestApp.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/02/23.
//

import SwiftUI
import TweetNestKit

#if os(iOS)
typealias ApplicationDelegateAdaptor = UIApplicationDelegateAdaptor
#elseif os(macOS)
typealias ApplicationDelegateAdaptor = NSApplicationDelegateAdaptor
#endif

@main
struct TweetNestApp: App {
    @ApplicationDelegateAdaptor(TweetNestAppDelegate.self) var delegate

    let session = TweetNestKit.Session.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, session.container.viewContext)
        }
    }
}
