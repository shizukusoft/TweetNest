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
        url: URL,
        context: NSManagedObjectContext
    ) throws -> DataAsset {
        let dataSHA512Hash = Data(SHA512.hash(data: data))

        let dataAssetFetchRequest: NSFetchRequest<DataAsset> = DataAsset.fetchRequest()
        dataAssetFetchRequest.predicate = NSPredicate(format: "url == %@", url as NSURL)
        dataAssetFetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        dataAssetFetchRequest.propertiesToFetch = ["dataSHA512Hash"]
        dataAssetFetchRequest.fetchLimit = 1

        let lastDataAsset = try context.fetch(dataAssetFetchRequest).first

        if let lastDataAsset = lastDataAsset, lastDataAsset.dataSHA512Hash == dataSHA512Hash || lastDataAsset.data.flatMap({ Data(SHA512.hash(data: $0)) }) == dataSHA512Hash {
            if lastDataAsset.dataSHA512Hash == nil {
                lastDataAsset.dataSHA512Hash = dataSHA512Hash
            }
            return lastDataAsset
        } else {
            let newDataAsset = DataAsset(context: context)
            newDataAsset.data = data
            newDataAsset.dataSHA512Hash = dataSHA512Hash
            newDataAsset.url = url

            return newDataAsset
        }
    }
}

extension DataAsset {
    @discardableResult
    static func dataAsset<T>(for url: URL, session: Session, context: NSManagedObjectContext, _ block: @escaping (DataAsset) throws -> T) async throws -> T {
        var urlRequest = URLRequest(url: url)
        urlRequest.allowsExpensiveNetworkAccess = TweetNestKitUserDefaults.standard.downloadsDataAssetsUsingExpensiveNetworkAccess

        let data = try await session.data(for: urlRequest)

        return try await context.perform(schedule: .enqueued) {
            try Task.checkCancellation()

            return try block(.dataAsset(data: data, url: url, context: context))
        }
    }
}
