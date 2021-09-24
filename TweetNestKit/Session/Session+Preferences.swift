//
//  Session+Preferences.swift
//  Session+Preferences
//
//  Created by Jaehong Kang on 2021/09/05.
//

import Foundation
import CoreData

extension Session {
    public nonisolated func preferences(for context: NSManagedObjectContext) -> ManagedPreferences {
        context.performAndWait {
            let fetchReuqest: NSFetchRequest<ManagedPreferences> = ManagedPreferences.fetchRequest()
            fetchReuqest.sortDescriptors = [NSSortDescriptor(keyPath: \ManagedPreferences.modificationDate, ascending: false)]
            fetchReuqest.fetchLimit = 1

            return (try? context.fetch(fetchReuqest).first) ?? ManagedPreferences(context: context)
        }
    }
}
