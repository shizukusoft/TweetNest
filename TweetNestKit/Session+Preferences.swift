//
//  Session+Preferences.swift
//  Session+Preferences
//
//  Created by Jaehong Kang on 2021/09/05.
//

import Foundation
import CoreData

extension Session {
    public struct Preferences {
        public var lastCleansed: Date = .distantPast
    }

    public var preferences: Preferences {
        get {
            let context = persistentContainer.newBackgroundContext()

            return context.performAndWait {
                let fetchReuqest: NSFetchRequest<ManagedPreferences> = ManagedPreferences.fetchRequest()
                fetchReuqest.sortDescriptors = [NSSortDescriptor(keyPath: \ManagedPreferences.modificationDate, ascending: false)]
                fetchReuqest.fetchLimit = 1

                return (try? context.fetch(fetchReuqest).first?.preferences) ?? Preferences()
            }
        }
        set {
            let context = persistentContainer.newBackgroundContext()

            return context.performAndWait {
                let fetchReuqest: NSFetchRequest<ManagedPreferences> = ManagedPreferences.fetchRequest()
                fetchReuqest.sortDescriptors = [NSSortDescriptor(keyPath: \ManagedPreferences.modificationDate, ascending: false)]
                fetchReuqest.fetchLimit = 1

                let preferences = (try? context.fetch(fetchReuqest).first) ?? ManagedPreferences(context: context)

                preferences.modificationDate = Date()
                preferences.preferences = newValue

                try! context.save()
            }
        }
    }
}

extension Session.Preferences: Codable { }

extension Session.Preferences {
    @objc(TWNKSessionPreferencesTransformer)
    class Transformer: ValueTransformer {
        override class func transformedValueClass() -> AnyClass {
            NSData.self
        }

        override func transformedValue(_ value: Any?) -> Any? {
            guard let value = value as? Session.Preferences? else {
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

            return try? PropertyListDecoder().decode(Session.Preferences.self, from: value as Data)
        }
    }
}
