//
//  SessionEnvironmentKey.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2022/08/27.
//

import SwiftUI
import TweetNestKit

struct SessionEnvironmentKey: EnvironmentKey {
    static let defaultValue: Session = {
        #if DEBUG
        if ProcessInfo.processInfo.isPreview {
            return Session.preview
        } else {
            return Session.shared
        }
        #else
        return Session.shared
        #endif
    }()
}

extension EnvironmentValues {
    var session: Session {
        get { self[SessionEnvironmentKey.self] }
        set { self[SessionEnvironmentKey.self] = newValue }
    }
}
