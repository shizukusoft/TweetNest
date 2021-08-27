//
//  SessionEnvironmentKey.swift
//  SessionEnvironmentKey
//
//  Created by Jaehong Kang on 2021/08/27.
//

import SwiftUI
import TweetNestKit

public struct SessionEnvironmentKey: EnvironmentKey {
    public static var defaultValue: Session = .shared
}

public extension EnvironmentValues {
    var session: Session {
        get { self[SessionEnvironmentKey.self] }
        set { self[SessionEnvironmentKey.self] = newValue }
    }
}
