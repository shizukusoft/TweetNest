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
    public subscript<T>(dynamicMember keyPath: WritableKeyPath<Preferences, T>) -> T {
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
        public var fetchProfileHeaderImages: Bool = false
    }
}

extension ManagedPreferences.Preferences: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let defaultPreferences = ManagedPreferences.Preferences()

        self.lastCleansed = try container.decodeIfPresent(Date.self, forKey: .lastCleansed) ?? defaultPreferences.lastCleansed
        self.fetchProfileHeaderImages = try container.decodeIfPresent(Bool.self, forKey: .fetchProfileHeaderImages) ?? defaultPreferences.fetchProfileHeaderImages
    }
}

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

            return try? PropertyListDecoder().decode(ManagedPreferences.Preferences.self, from: value as Data)
        }
    }
}

extension ManagedPreferences {
    struct Key {
        static let preferences = "preferences"
        static let modificationDate = "modificationDate"
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

            willChangeValue(forKey: Key.modificationDate)
            defer { didChangeValue(forKey: Key.modificationDate) }

            setPrimitiveValue(Date(), forKey: Key.modificationDate)
        }
    }
}
