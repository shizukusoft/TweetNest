//
//  UsersSpotlightDelegate.swift
//  UsersSpotlightDelegate
//
//  Created by Jaehong Kang on 2021/08/06.
//

import CoreData
import CoreSpotlight

class UsersSpotlightDelegate: NSCoreDataCoreSpotlightDelegate {
    override func domainIdentifier() -> String {
        "\(Bundle.module.bundleIdentifier!).users"
    }

    override func indexName() -> String? {
        "users-index"
    }

    override func attributeSet(for object: NSManagedObject) -> CSSearchableItemAttributeSet? {
        if let user = object as? User {
            let attributeSet = CSSearchableItemAttributeSet(contentType: .contact)

            let sortedUserDatas = user.sortedUserDatas

            attributeSet.identifier = user.id
            attributeSet.displayName = sortedUserDatas?.last?.name
            attributeSet.alternateNames = (sortedUserDatas?.last?.username).flatMap { ["@\($0)"] }
            attributeSet.thumbnailData = sortedUserDatas?.last?.profileImageData
            attributeSet.keywords = (sortedUserDatas?.compactMap(\.name) ?? []) + (sortedUserDatas?.compactMap(\.username) ?? [])

            return attributeSet
        }

        return nil
    }
}
