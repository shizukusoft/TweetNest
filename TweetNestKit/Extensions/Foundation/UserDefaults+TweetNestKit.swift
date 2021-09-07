//
//  UserDefaults+TweetNestKit.swift
//  UserDefaults+TweetNestKit
//
//  Created by Jaehong Kang on 2021/09/07.
//

import Foundation

extension UserDefaults {
    public static var tweetNestKit: UserDefaults = UserDefaults(suiteName: Session.applicationGroupIdentifier)!
}

public struct TweetNestUserDefaultsKeyName: RawRepresentable {
    public typealias RawValue = String
    public var rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension UserDefaults {
    subscript<T>(key: TweetNestUserDefaultsKeyName, type: T.Type) -> T? {
        get {
            object(forKey: key.rawValue) as? T
        }
        set {
            set(newValue, forKey: key.rawValue)
        }
    }
    
    subscript<T>(key: TweetNestUserDefaultsKeyName) -> T? {
        get {
            object(forKey: key.rawValue) as? T
        }
        set {
            set(newValue, forKey: key.rawValue)
        }
    }
}

#if canImport(SwiftUI)
import SwiftUI

extension AppStorage {
    public init(wrappedValue: Value, _ key: TweetNestUserDefaultsKeyName) where Value == Bool {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: .tweetNestKit)
    }
}
#endif
