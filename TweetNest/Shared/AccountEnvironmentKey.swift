//
//  AccountEnvironmentKey.swift
//  AccountEnvironmentKey
//
//  Created by Jaehong Kang on 2021/08/15.
//

import SwiftUI
import TweetNestKit

public struct AccountEnvironmentKey: EnvironmentKey {
    public static var defaultValue: ManagedAccount?
}

public extension EnvironmentValues {
    var account: ManagedAccount? {
        get { self[AccountEnvironmentKey.self] }
        set { self[AccountEnvironmentKey.self] = newValue }
    }
}
