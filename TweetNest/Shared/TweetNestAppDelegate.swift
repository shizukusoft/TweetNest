//
//  TweetNestAppDelegate.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/03/22.
//

import Foundation
import UserNotifications
import TweetNestKit

@MainActor
class TweetNestAppDelegate: NSObject, ObservableObject {
    let session = Session.shared
}

extension TweetNestAppDelegate: UNUserNotificationCenterDelegate {
    
}
