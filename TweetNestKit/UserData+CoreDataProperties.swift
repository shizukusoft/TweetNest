//
//  UserData+CoreDataProperties.swift
//  TweetNestKit
//
//  Created by Jaehong Kang on 2021/02/24.
//
//

import Foundation
import CoreData


extension UserData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserData> {
        return NSFetchRequest<UserData>(entityName: "UserData")
    }

    @NSManaged public var creationDate: Date?
    @NSManaged public var id: Int64

}

extension UserData : Identifiable {

}
