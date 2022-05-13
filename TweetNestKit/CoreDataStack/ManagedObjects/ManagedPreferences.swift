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

extension ManagedPreferences {
    public static func managedPreferences(for context: NSManagedObjectContext) -> ManagedPreferences {
        let fetchReuqest: NSFetchRequest<ManagedPreferences> = ManagedPreferences.fetchRequest()
        fetchReuqest.sortDescriptors = [NSSortDescriptor(keyPath: \ManagedPreferences.modificationDate, ascending: false)]
        fetchReuqest.fetchLimit = 1
        fetchReuqest.returnsObjectsAsFaults = false

        return (try? context.fetch(fetchReuqest).first) ?? ManagedPreferences(context: context)
    }
}
