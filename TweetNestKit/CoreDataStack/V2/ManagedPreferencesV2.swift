//
//  ManagedPreferencesV2+CoreDataClass.swift
//  TweetNestKit
//
//  Created by 강재홍 on 2022/05/02.
//
//

import Foundation
import CoreData

@dynamicMemberLookup
public class ManagedPreferencesV2: NSManagedObject {
    public subscript<T>(dynamicMember keyPath: WritableKeyPath<Preferences, T>) -> T {
        get {
            preferences[keyPath: keyPath]
        }
        set {
            preferences[keyPath: keyPath] = newValue
        }
    }
}

class ManagedPreferencesV2Transformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        NSData.self
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let value = value as? ManagedPreferencesV2.Preferences? else {
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

        return try? PropertyListDecoder().decode(ManagedPreferencesV2.Preferences.self, from: value as Data)
    }
}

extension ManagedPreferencesV2 {
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

extension ManagedPreferencesV2{
    public static func managedPreferences(for context: NSManagedObjectContext) -> ManagedPreferencesV2  {
        let fetchReuqest = ManagedPreferencesV2.fetchRequest()
        fetchReuqest.sortDescriptors = [NSSortDescriptor(keyPath: \ManagedPreferencesV2.modificationDate, ascending: false)]
        fetchReuqest.fetchLimit = 1
        fetchReuqest.returnsObjectsAsFaults = false

        return (try? context.fetch(fetchReuqest).first) ?? ManagedPreferencesV2(context: context)
    }
}
