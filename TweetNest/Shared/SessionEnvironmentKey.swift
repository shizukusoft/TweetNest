//
//  SessionEnvironmentKey.swift
//  SessionEnvironmentKey
//
//  Created by Jaehong Kang on 2021/08/27.
//

import SwiftUI
import TweetNestKit

public struct SessionEnvironmentKey: EnvironmentKey {
    #if DEBUG
    public static var defaultValue: Session = {
        if CommandLine.arguments.contains("-com.tweetnest.TweetNest.Preview") {
            return Session.preview
        } else {
            return Session.shared
        }
    }()
    #else
    public static var defaultValue = Session.shared
    #endif
}

public extension EnvironmentValues {
    var session: Session {
        get { self[SessionEnvironmentKey.self] }
        set { self[SessionEnvironmentKey.self] = newValue }
    }
}
