//
//  ManagedDataAssetV2+CoreDataProperties.swift
//  TweetNestKit
//
//  Created by 강재홍 on 2022/05/02.
//
//

import Foundation
import CoreData


extension ManagedDataAssetV2 {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedDataAssetV2> {
        return NSFetchRequest<ManagedDataAssetV2>(entityName: "DataAsset")
    }

    @NSManaged public var creationDate: Date?
    @NSManaged public var data: Data?
    @NSManaged public var dataMIMEType: String?
    @NSManaged public var dataSHA512Hash: Data?
    @NSManaged public var url: URL?

}

extension ManagedDataAssetV2 : Identifiable {

}
