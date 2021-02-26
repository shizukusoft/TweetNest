//
//  TweetNestApp.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/02/23.
//

import SwiftUI
import TweetNestKit

@main
struct TweetNestApp: App {
    let session = TweetNestKit.Session.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, session.container.viewContext)
        }
    }
}
