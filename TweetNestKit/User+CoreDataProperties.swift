//
//  User+CoreDataProperties.swift
//  TweetNestKit
//
//  Created by Jaehong Kang on 2021/02/25.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var creationDate: Date?
    @NSManaged public var id: String?
    @NSManaged public var account: Account?

}

extension User : Identifiable {

}
