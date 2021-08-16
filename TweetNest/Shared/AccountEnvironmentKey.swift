//
//  AccountEnvironmentKey.swift
//  AccountEnvironmentKey
//
//  Created by Jaehong Kang on 2021/08/15.
//

import SwiftUI
import TweetNestKit

public struct AccountEnvironmentKey: EnvironmentKey {
    public static var defaultValue: Account? = nil
}

public extension EnvironmentValues {
    var account: Account? {
        get { self[AccountEnvironmentKey.self] }
        set { self[AccountEnvironmentKey.self] = newValue }
    }
}
