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
public class ManagedPreferences: ManagedObject {
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
    }

    public dynamic var preferences: Preferences {
        get {
            willAccessValue(forKey: Key.preferences)
            let preferences = primitiveValue(forKey: Key.preferences) as? Preferences
            didAccessValue(forKey: Key.preferences)

            guard let preferences = preferences else {
                self.preferences = Preferences()
                return self.preferences
            }

            return preferences
        }
        set {
            willChangeValue(forKey: Key.preferences)
            setPrimitiveValue(newValue, forKey: Key.preferences)
            didChangeValue(forKey: Key.preferences)

            self.modificationDate = Date()
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
