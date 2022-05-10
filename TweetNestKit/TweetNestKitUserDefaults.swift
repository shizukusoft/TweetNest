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
        case downloadsDataAssetsUsingExpensiveNetworkAccess = "TWNKDownloadsDataAssetsUsingExpensiveNetworkAccess"
        case lastPersistentHistoryTokenData = "TWNKLastPersistentHistoryTokenData"
        case fetchNewDataInterval = "TWNKFetchNewDataInterval"
        case lastFetchNewDataDate = "TWNKLastFetchNewData"
        case lastCleansedDate = "TWNKLastCleansed"

        @available(*, deprecated, renamed: "lastFetchNewDataDate")
        case lastBackgroundUpdate = "TWNKLastBackgroundUpdate"

        @available(*, deprecated, renamed: "lastPersistentHistoryToken")
        case lastPersistentHistoryTransactionTimestamp = "TWNKLastPersistentHistoryTransactionTimestamp"
    }

    private static let _standard = TweetNestKitUserDefaults(suiteName: Session.applicationGroupIdentifier)!
    public override class var standard: TweetNestKitUserDefaults {
        _standard
    }

    @objc public dynamic var isBackgroundUpdateEnabled: Bool {
        get { object(forKey: DefaultsKeys.isBackgroundUpdateEnabled.rawValue) as? Bool != false }
        set { setValue(newValue, forKey: DefaultsKeys.isBackgroundUpdateEnabled.rawValue) }
    }

    @objc public dynamic var downloadsDataAssetsUsingExpensiveNetworkAccess: Bool {
        get { object(forKey: DefaultsKeys.downloadsDataAssetsUsingExpensiveNetworkAccess.rawValue) as? Bool != false }
        set { setValue(newValue, forKey: DefaultsKeys.downloadsDataAssetsUsingExpensiveNetworkAccess.rawValue) }
    }

    @objc public dynamic var lastPersistentHistoryTokenData: Data? {
        get { object(forKey: DefaultsKeys.lastPersistentHistoryTokenData.rawValue) as? Data }
        set { setValue(newValue, forKey: DefaultsKeys.lastPersistentHistoryTokenData.rawValue) }
    }

    @objc public dynamic var fetchNewDataInterval: TimeInterval {
        get { object(forKey: DefaultsKeys.fetchNewDataInterval.rawValue) as? TimeInterval ?? 10 * 60 }
        set { setValue(newValue, forKey: DefaultsKeys.fetchNewDataInterval.rawValue) }
    }

    @objc public dynamic var lastFetchNewDataDate: Date {
        get { object(forKey: DefaultsKeys.lastFetchNewDataDate.rawValue) as? Date ?? .distantPast }
        set { setValue(newValue, forKey: DefaultsKeys.lastFetchNewDataDate.rawValue) }
    }

    @objc public dynamic var lastCleansedDate: Date {
        get { object(forKey: DefaultsKeys.lastCleansedDate.rawValue) as? Date ?? .distantPast }
        set { setValue(newValue, forKey: DefaultsKeys.lastCleansedDate.rawValue) }
    }

    public override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        switch key {
        case "isBackgroundUpdateEnabled":
            return super.keyPathsForValuesAffectingValue(forKey: key).union([DefaultsKeys.isBackgroundUpdateEnabled.rawValue])
        case "downloadsDataAssetsUsingExpensiveNetworkAccess":
            return super.keyPathsForValuesAffectingValue(forKey: key).union([DefaultsKeys.downloadsDataAssetsUsingExpensiveNetworkAccess.rawValue])
        case "lastPersistentHistoryTokenData":
            return super.keyPathsForValuesAffectingValue(forKey: key).union([DefaultsKeys.lastPersistentHistoryTokenData.rawValue])
        case "fetchNewDataInterval":
            return super.keyPathsForValuesAffectingValue(forKey: key).union([DefaultsKeys.fetchNewDataInterval.rawValue])
        case "lastFetchNewDataDate":
            return super.keyPathsForValuesAffectingValue(forKey: key).union([DefaultsKeys.lastFetchNewDataDate.rawValue])
        case "lastCleansedDate":
            return super.keyPathsForValuesAffectingValue(forKey: key).union([DefaultsKeys.lastCleansedDate.rawValue])
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

    public init(wrappedValue: Value, _ key: TweetNestKitUserDefaults.DefaultsKeys) where Value == Double {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: TweetNestKitUserDefaults.standard)
    }
}
#endif
