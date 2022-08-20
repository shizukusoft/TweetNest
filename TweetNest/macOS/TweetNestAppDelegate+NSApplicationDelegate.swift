//
//  TweetNestAppDelegate.swift
//  TweetNest (macOS)
//
//  Created by Jaehong Kang on 2021/03/22.
//

import AppKit
import UserNotifications

extension TweetNestAppDelegate: NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.registerForRemoteNotifications()
    }
}
