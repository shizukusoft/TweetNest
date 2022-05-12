//
//  ManagedUser+CoreDataProperties.swift
//  TweetNestKit
//
//  Created by 강재홍 on 2022/05/03.
//
//

import Foundation
import CoreData


extension ManagedUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedUser> {
        return NSFetchRequest<ManagedUser>(entityName: "User")
    }

    @NSManaged public var creationDate: Date?
    @NSManaged public var id: String?
    @NSManaged public var lastUpdateEndDate: Date?
    @NSManaged public var lastUpdateStartDate: Date?
    @NSManaged public var modificationDate: Date?

}

extension ManagedUser : Identifiable {

}
