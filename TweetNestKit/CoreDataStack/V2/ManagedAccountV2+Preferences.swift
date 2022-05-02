//
//  ManagedAccountV2+Preferences.swift
//  TweetNestKit
//
//  Created by 강재홍 on 2022/05/03.
//

import Foundation
import CoreData

extension ManagedAccountV2 {
    struct Key {
        static let preferences = "preferences"
    }

    public dynamic var preferences: Preferences {
        get {
            willAccessValue(forKey: Key.preferences)
            defer { didAccessValue(forKey: Key.preferences) }

            let preferences = primitiveValue(forKey: Key.preferences) as? Preferences

            guard let preferences = preferences else {
                self.preferences = Preferences()
                return self.preferences
            }

            return preferences
        }
        set {
            willChangeValue(forKey: Key.preferences)
            defer { didChangeValue(forKey: Key.preferences) }

            setPrimitiveValue(newValue, forKey: Key.preferences)
        }
    }
}

extension ManagedAccountV2 {
    public struct Preferences {
        public var fetchBlockingUsers: Bool = false
        public var fetchMutingUsers: Bool = false
    }
}

extension ManagedAccountV2.Preferences: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let defaultPreferences = ManagedAccountV2.Preferences()

        self.fetchBlockingUsers = try container.decodeIfPresent(Bool.self, forKey: .fetchBlockingUsers) ?? defaultPreferences.fetchBlockingUsers
        self.fetchMutingUsers = try container.decodeIfPresent(Bool.self, forKey: .fetchMutingUsers) ?? defaultPreferences.fetchMutingUsers
    }
}

class ManagedAccountV2PreferencesTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        NSData.self
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let value = value as? ManagedAccountV2.Preferences? else {
            preconditionFailure()
        }

        return value.flatMap {
            do {
                return try PropertyListEncoder().encode($0) as NSData
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let value = value as? NSData else {
            return nil
        }

        return try? PropertyListDecoder().decode(ManagedAccountV2.Preferences.self, from: value as Data)
    }
}
