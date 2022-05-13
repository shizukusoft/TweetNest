//
//  ManagedUserDataAsset+CoreDataProperties.swift
//  TweetNestKit
//
//  Created by 강재홍 on 2022/05/03.
//
//

import Foundation
import CoreData

extension ManagedUserDataAsset {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedUserDataAsset> {
        return NSFetchRequest<ManagedUserDataAsset>(entityName: "UserDataAsset")
    }

    @NSManaged public var creationDate: Date?
    @NSManaged public var data: Data?
    @NSManaged public var dataMIMEType: String?
    @NSManaged public var dataSHA512Hash: Data?
    @NSManaged public var url: URL?

}

extension ManagedUserDataAsset: Identifiable {

}
