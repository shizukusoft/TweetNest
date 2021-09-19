//
//  ManagedPreferences+CoreDataProperties.swift
//  ManagedPreferences
//
//  Created by Jaehong Kang on 2021/09/05.
//
//

import Foundation
import CoreData

extension ManagedPreferences {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedPreferences> {
        return NSFetchRequest<ManagedPreferences>(entityName: "Preferences")
    }

    @NSManaged public var modificationDate: Date?
}

extension ManagedPreferences: Identifiable {

}
