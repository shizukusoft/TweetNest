//
//  PersistentContainer+Migration.swift
//  TweetNestKit
//
//  Created by 강재홍 on 2022/05/03.
//

import Foundation
import CoreData

// Workaround: https://forums.swift.org/t/suppressing-deprecated-warnings/53970/6
private protocol PersistentContainerMigrationProtocol {
    func _migrateIfNeeded() throws
}

@available(*, deprecated)
extension PersistentContainer: PersistentContainerMigrationProtocol {
    fileprivate func _migrateIfNeeded() throws {
        if
            FileManager.default.fileExists(atPath: Self.V1.defaultPersistentStoreURL.path)
        {
            try V3.migrateFromV1()
        }
    }
}

extension PersistentContainer {
    func migrateIfNeeded() throws {
        try (self as PersistentContainerMigrationProtocol)._migrateIfNeeded()
    }
}
