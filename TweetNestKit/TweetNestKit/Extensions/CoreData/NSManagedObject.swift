//
//  NSManagedObject.swift
//  TweetNestKit
//
//  Created by Jaehong Kang on 2022/11/06.
//

import CoreData

extension NSManagedObject {
    public var values: [String: Any] {
        get {
            self.committedValues(forKeys: nil).merging(changedValues(), uniquingKeysWith: { $1 })
        }
        set {
            for (key, value) in newValue {
                self.setValue(value, forKey: key)
            }
        }
    }
}
