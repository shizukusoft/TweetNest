//
//  ManagedAccountV2+CoreDataProperties.swift
//  TweetNestKit
//
//  Created by 강재홍 on 2022/05/02.
//
//

import Foundation
import CoreData


extension ManagedAccountV2 {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedAccountV2> {
        return NSFetchRequest<ManagedAccountV2>(entityName: "Account")
    }

    @NSManaged public var creationDate: Date?
    @NSManaged public var preferringSortOrder: Int64
    @NSManaged public var token: String?
    @NSManaged public var tokenSecret: String?
    @NSManaged public var userID: String?

}

extension ManagedAccountV2 : Identifiable {

}
