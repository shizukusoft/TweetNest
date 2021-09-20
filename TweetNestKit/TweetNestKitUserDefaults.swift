//
//  TweetNestKitUserDefaults.swift
//  TweetNestKitUserDefaults
//
//  Created by Jaehong Kang on 2021/09/10.
//

import Foundation

final public class TweetNestKitUserDefaults: UserDefaults {
    public enum DefaultsKeys: String {
        case isBackgroundUpdateEnabled = "TWNKBackgroundUpdateEnabled"
        case lastBackgroundUpdate = "TWNKLastBackgroundUpdate"
        case downloadsDataAssetsUsingExpensiveNetworkAccess = "TWNKDownloadsDataAssetsUsingExpensiveNetworkAccess"
        case persistentHistoryToken = "TWNKPersistentHistoryToken"
    }

    private static let _standard = TweetNestKitUserDefaults(suiteName: Session.applicationGroupIdentifier)!
    public override class var standard: TweetNestKitUserDefaults {
        _standard
    }

    @objc public dynamic var isBackgroundUpdateEnabled: Bool {
        get { object(forKey: DefaultsKeys.isBackgroundUpdateEnabled.rawValue) as? Bool != false }
        set { setValue(newValue, forKey: DefaultsKeys.isBackgroundUpdateEnabled.rawValue) }
    }

    @objc public dynamic var lastBackgroundUpdate: Date {
        get { object(forKey: DefaultsKeys.lastBackgroundUpdate.rawValue) as? Date ?? .distantPast }
        set { setValue(newValue, forKey: DefaultsKeys.lastBackgroundUpdate.rawValue) }
    }

    @objc public dynamic var downloadsDataAssetsUsingExpensiveNetworkAccess: Bool {
        get { object(forKey: DefaultsKeys.downloadsDataAssetsUsingExpensiveNetworkAccess.rawValue) as? Bool != false }
        set { setValue(newValue, forKey: DefaultsKeys.downloadsDataAssetsUsingExpensiveNetworkAccess.rawValue) }
    }

    @objc public dynamic var persistentHistoryToken: Data? {
        get { object(forKey: DefaultsKeys.persistentHistoryToken.rawValue) as? Data }
        set { setValue(newValue, forKey: DefaultsKeys.persistentHistoryToken.rawValue) }
    }

    public override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        switch key {
        case "isBackgroundUpdateEnabled":
            return super.keyPathsForValuesAffectingValue(forKey: key).union([DefaultsKeys.isBackgroundUpdateEnabled.rawValue])
        case "lastBackgroundUpdate":
            return super.keyPathsForValuesAffectingValue(forKey: key).union([DefaultsKeys.lastBackgroundUpdate.rawValue])
        case "downloadsDataAssetsUsingExpensiveNetworkAccess":
            return super.keyPathsForValuesAffectingValue(forKey: key).union([DefaultsKeys.downloadsDataAssetsUsingExpensiveNetworkAccess.rawValue])
        case "persistentHistoryToken":
            return super.keyPathsForValuesAffectingValue(forKey: key).union([DefaultsKeys.persistentHistoryToken.rawValue])
        default:
            return super.keyPathsForValuesAffectingValue(forKey: key)
        }
    }
}

#if canImport(SwiftUI)
import SwiftUI

extension AppStorage {
    public init(wrappedValue: Value, _ key: TweetNestKitUserDefaults.DefaultsKeys) where Value == Bool {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: TweetNestKitUserDefaults.standard)
    }
}
#endif
