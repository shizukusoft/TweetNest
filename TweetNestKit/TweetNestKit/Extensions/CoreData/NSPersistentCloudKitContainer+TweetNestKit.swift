//
//  NSPersistentCloudKitContainer+TweetNestKit.swift
//  TweetNestKit
//
//  Created by Jaehong Kang on 2022/10/21.
//

import CoreData

extension NSPersistentCloudKitContainer.Event {
    @inlinable
    public var result: Result<Void, Error>? {
        guard endDate != nil else {
            return nil
        }

        if let error = error {
            return .failure(error)
        } else if succeeded {
            return .success(())
        } else {
            return nil
        }
    }
}
