//
//  ManagedDataAsset+CoreDataClass.swift
//  TweetNestKit
//
//  Created by 강재홍 on 2022/05/03.
//
//

import Foundation
import CoreData
import CryptoKit

public class ManagedDataAsset: NSManagedObject {

}

extension ManagedDataAsset {
    @discardableResult
    static func dataAsset(
        data: Data,
        dataMIMEType: String?,
        url: URL,
        creationDate: Date = Date(),
        context: NSManagedObjectContext
    ) throws -> ManagedDataAsset {
        let dataSHA512Hash = Data(SHA512.hash(data: data))

        let dataAssetFetchRequest = ManagedDataAsset.fetchRequest()
        dataAssetFetchRequest.predicate = NSPredicate(format: "url == %@", url as NSURL)
        dataAssetFetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        dataAssetFetchRequest.propertiesToFetch = ["dataMIMEType", "dataSHA512Hash"]
        dataAssetFetchRequest.returnsObjectsAsFaults = false
        dataAssetFetchRequest.fetchLimit = 1

        let lastDataAsset = try context.fetch(dataAssetFetchRequest).first

        if let lastDataAsset = lastDataAsset, lastDataAsset.dataSHA512Hash == dataSHA512Hash, lastDataAsset.dataMIMEType == dataMIMEType {
            return lastDataAsset
        } else {
            let newDataAsset = ManagedDataAsset(context: context)
            newDataAsset.data = data
            newDataAsset.dataSHA512Hash = dataSHA512Hash
            newDataAsset.dataMIMEType = dataMIMEType
            newDataAsset.url = url
            newDataAsset.creationDate = creationDate

            return newDataAsset
        }
    }
}