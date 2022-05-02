//
//  ManagedUserV2+CoreDataProperties.swift
//  TweetNestKit
//
//  Created by 강재홍 on 2022/05/02.
//
//

import Foundation
import CoreData


extension ManagedUserV2 {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedUserV2> {
        return NSFetchRequest<ManagedUserV2>(entityName: "User")
    }

    @NSManaged public var creationDate: Date?
    @NSManaged public var id: String?
    @NSManaged public var lastUpdateEndDate: Date?
    @NSManaged public var lastUpdateStartDate: Date?
    @NSManaged public var modificationDate: Date?

}

extension ManagedUserV2 : Identifiable {

}
