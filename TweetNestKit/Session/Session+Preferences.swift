//
//  Session+Preferences.swift
//  Session+Preferences
//
//  Created by Jaehong Kang on 2021/09/05.
//

import Foundation
import CoreData

extension Session {
    @MainActor
    public var preferences: ManagedPreferences {
        get {
            let context = persistentContainer.newBackgroundContext()

            let objectID: NSManagedObjectID = context.performAndWait {
                let fetchReuqest: NSFetchRequest<ManagedPreferences> = ManagedPreferences.fetchRequest()
                fetchReuqest.sortDescriptors = [NSSortDescriptor(keyPath: \ManagedPreferences.modificationDate, ascending: false)]
                fetchReuqest.fetchLimit = 1

                defer {
                    if context.hasChanges {
                        try? context.save()
                    }
                }

                return ((try? context.fetch(fetchReuqest).first) ?? ManagedPreferences(context: context)).objectID
            }

            return persistentContainer.viewContext.object(with: objectID) as! ManagedPreferences
        }
        set {
            let context = persistentContainer.newBackgroundContext()
            let newValue = newValue.preferences

            context.perform {
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
