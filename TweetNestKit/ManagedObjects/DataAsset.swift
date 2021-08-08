//
//  DataAsset.swift
//  DataAsset
//
//  Created by Jaehong Kang on 2021/08/08.
//
//

import Foundation
import CoreData

@objc(TWNKDataAsset)
public class DataAsset: NSManagedObject {
    public override func awakeFromInsert() {
        setPrimitiveValue(Date(), forKey: "creationDate")
    }
}

extension DataAsset {
    static func dataAsset(
        data: Data,
        url: URL,
        context: NSManagedObjectContext
    ) throws -> DataAsset {
        let dataAssetFetchRequest: NSFetchRequest<DataAsset> = DataAsset.fetchRequest()
        dataAssetFetchRequest.predicate = NSPredicate(format: "url == %@", url as NSURL)
        dataAssetFetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        dataAssetFetchRequest.fetchLimit = 1

        let lastDataAsset = try context.fetch(dataAssetFetchRequest).first

        if let lastDataAsset = lastDataAsset, lastDataAsset.data == data {
            return lastDataAsset
        } else {
            let newDataAsset = DataAsset(context: context)
            newDataAsset.data = data
            newDataAsset.url = url

            return newDataAsset
        }
    }
}

extension DataAsset {
    static func dataAsset(for url: URL, session: Session, context: NSManagedObjectContext) async throws -> DataAsset {
        let dataURL = try await session.download(from: url)
        let data = try Data(contentsOf: dataURL)

        return try await context.perform {
            try .dataAsset(data: data, url: url, context: context)
        }
    }
}
