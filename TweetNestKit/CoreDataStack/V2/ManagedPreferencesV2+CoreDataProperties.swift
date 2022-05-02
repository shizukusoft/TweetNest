//
//  ManagedPreferencesV2+CoreDataProperties.swift
//  TweetNestKit
//
//  Created by 강재홍 on 2022/05/02.
//
//

import Foundation
import CoreData


extension ManagedPreferencesV2 {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedPreferencesV2> {
        return NSFetchRequest<ManagedPreferencesV2>(entityName: "Preferences")
    }

    @NSManaged public var modificationDate: Date?

}

extension ManagedPreferencesV2 : Identifiable {

}
