//
//  PersistentCloudKitContainer.swift
//  TweetNestKit
//
//  Created by Jaehong Kang on 2021/02/24.
//

import CloudKit
import CoreData

class PersistentCloudKitContainer: NSPersistentCloudKitContainer {
    override class func defaultDirectoryURL() -> URL {
        return FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.io.sinoru.TweetNestKit")?
            .appendingPathComponent("Application Support/TweetNestKit") ?? super.defaultDirectoryURL()
    }
}
