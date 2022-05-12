//
//  ManagedDataAsset+CoreDataProperties.swift
//  TweetNestKit
//
//  Created by 강재홍 on 2022/05/03.
//
//

import Foundation
import CoreData


extension ManagedDataAsset {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedDataAsset> {
        return NSFetchRequest<ManagedDataAsset>(entityName: "DataAsset")
    }

    @NSManaged public var creationDate: Date?
    @NSManaged public var data: Data?
    @NSManaged public var dataMIMEType: String?
    @NSManaged public var dataSHA512Hash: Data?
    @NSManaged public var url: URL?

}

extension ManagedDataAsset : Identifiable {

}
