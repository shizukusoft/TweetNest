//
//  DataAsset.swift
//  DataAsset
//
//  Created by Jaehong Kang on 2021/08/08.
//
//

import Foundation
import CoreData
import CryptoKit

public class DataAsset: NSManagedObject {
    public override func awakeFromInsert() {
        setPrimitiveValue(Date(), forKey: "creationDate")
    }
}

extension DataAsset {
    @discardableResult
    static func dataAsset(
        data: Data,
        dataMIMEType: String?,
        url: URL,
        context: NSManagedObjectContext
    ) throws -> DataAsset {
        let dataSHA512Hash = Data(SHA512.hash(data: data))

        let dataAssetFetchRequest: NSFetchRequest<DataAsset> = DataAsset.fetchRequest()
        dataAssetFetchRequest.predicate = NSPredicate(format: "url == %@", url as NSURL)
        dataAssetFetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        dataAssetFetchRequest.propertiesToFetch = ["dataMIMEType", "dataSHA512Hash"]
        dataAssetFetchRequest.returnsObjectsAsFaults = false
        dataAssetFetchRequest.fetchLimit = 1

        let lastDataAsset = try context.fetch(dataAssetFetchRequest).first

        if let lastDataAsset = lastDataAsset, lastDataAsset.dataSHA512Hash == dataSHA512Hash, lastDataAsset.dataMIMEType == dataMIMEType {
            return lastDataAsset
        } else {
            let newDataAsset = DataAsset(context: context)
            newDataAsset.data = data
            newDataAsset.dataSHA512Hash = dataSHA512Hash
            newDataAsset.dataMIMEType = dataMIMEType
            newDataAsset.url = url

            return newDataAsset
        }
    }
}
