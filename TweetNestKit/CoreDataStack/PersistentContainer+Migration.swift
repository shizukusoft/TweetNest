//
//  PersistentContainer+Migration.swift
//  TweetNestKit
//
//  Created by 강재홍 on 2022/05/03.
//

import Foundation
import CoreData

protocol PersistentContainerMigrationProtocol {
    func migrateIfNeeded() throws
}

@available(*, deprecated) // Workaround: https://forums.swift.org/t/suppressing-deprecated-warnings/53970/6
extension PersistentContainer: PersistentContainerMigrationProtocol {
    func migrateIfNeeded() throws {
        if FileManager.default.fileExists(atPath: Self.V1.defaultPersistentStoreURL.path) {
            try V3.migrateFromV1()
        }
    }
}
