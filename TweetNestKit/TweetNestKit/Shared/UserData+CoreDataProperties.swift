//
//  UserData+CoreDataProperties.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/02/26.
//
//

import Foundation
import CoreData


extension UserData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserData> {
        return NSFetchRequest<UserData>(entityName: "UserData")
    }

    @NSManaged public var creationDate: Date?
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var profileImageURL: URL?
    @NSManaged public var username: String?

}

extension UserData : Identifiable {

}
