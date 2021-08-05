//
//  Session+TwitterAPIConfiguration.swift
//  TweetNestKit
//
//  Created by Jaehong Kang on 2021/08/03.
//

import Foundation
import CloudKit

extension Session {
    public struct TwitterAPIConfiguration {
        public var apiKey: String
        public var apiKeySecret: String

        public init(apiKey: String, apiKeySecret: String) {
            self.apiKey = apiKey
            self.apiKeySecret = apiKeySecret
        }
    }
}

extension Session.TwitterAPIConfiguration {
    static var iCloud: Self {
        get async throws {
            let container = CKContainer(identifier: Session.cloudKitIdentifier)
            let database = container.publicCloudDatabase

            let query = CKQuery(recordType: "TwitterAPIConfiguration", predicate: NSPredicate(value: true))
            query.sortDescriptors = [NSSortDescriptor(key: "modificationDate", ascending: true)]

            let records = try await database.perform(query, inZoneWith: .default)

            guard let apiKey: String = records.last?["apiKey"] else {
                throw SessionError.noAPIKey
            }

            guard let apiKeySecret: String = records.last?["apiKeySecret"] else {
                throw SessionError.noAPIKeySecret
            }

            return self.init(apiKey: apiKey, apiKeySecret: apiKeySecret)
        }
    }
}
