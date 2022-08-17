//
//  TweetNestAppShortcuts.swift
//  TweetNest App Intents Extension
//
//  Created by Jaehong Kang on 2022/08/17.
//

import AppIntents

struct TweetNestAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: FetchNewDataIntent(),
            phrases: ["Fetch \(.applicationName)"]
        )
        AppShortcut(
            intent: FetchNewAccountDataIntent(),
            phrases: ["Fetch \(.applicationName) for a account"]
        )
    }
}
