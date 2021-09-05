//
//  Preferences+CoreDataProperties.swift
//  Preferences
//
//  Created by Jaehong Kang on 2021/09/05.
//
//

import Foundation
import CoreData

extension Preferences {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Preferences> {
        return NSFetchRequest<Preferences>(entityName: "Preferences")
    }

    @NSManaged public var modificationDate: Date?
}

extension Preferences : Identifiable {

}
