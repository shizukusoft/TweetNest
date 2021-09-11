//
//  DataAsset+CoreDataProperties.swift
//  DataAsset
//
//  Created by Jaehong Kang on 2021/08/08.
//
//

import Foundation
import CoreData

extension DataAsset {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DataAsset> {
        return NSFetchRequest<DataAsset>(entityName: "DataAsset")
    }

    @NSManaged public var data: Data?
    @NSManaged public var dataSHA512Hash: Data?
    @NSManaged public var url: URL?
    @NSManaged public var creationDate: Date?

}

extension DataAsset: Identifiable {

}
