//
//  ManagedPreferences+CoreDataClass.swift
//  ManagedPreferences
//
//  Created by Jaehong Kang on 2021/09/05.
//
//

import Foundation
import CoreData

@dynamicMemberLookup
public class ManagedPreferences: NSManagedObject {

    subscript<T>(dynamicMember keyPath: WritableKeyPath<Preferences, T>) -> T {
        get {
            preferences[keyPath: keyPath]
        }
        set {
            preferences[keyPath: keyPath] = newValue
        }
    }
}

extension ManagedPreferences {
    public struct Preferences {
        public var lastCleansed: Date = .distantPast
    }
}

extension ManagedPreferences.Preferences: Codable { }

extension ManagedPreferences.Preferences {
    @objc(TWNKManagedPreferencesTransformer)
    class Transformer: ValueTransformer {
        override class func transformedValueClass() -> AnyClass {
            NSData.self
        }

        override func transformedValue(_ value: Any?) -> Any? {
            guard let value = value as? ManagedPreferences.Preferences? else {
                preconditionFailure()
            }

            return value.flatMap {
                try! PropertyListEncoder().encode($0) as NSData
            }
        }

        override func reverseTransformedValue(_ value: Any?) -> Any? {
            guard let value = value as? NSData else {
                return nil
            }

            return try? PropertyListDecoder().decode(ManagedPreferences.Preferences.self, from: value as Data)
        }
    }
}

extension ManagedPreferences {
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
