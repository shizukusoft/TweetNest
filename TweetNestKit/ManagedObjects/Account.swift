//
//  Account.swift
//  TweetNestKit
//
//  Created by Jaehong Kang on 2021/02/24.
//

import Foundation
import CoreData

@objc(TWNKAccount)
public class Account: NSManagedObject {
    public override func awakeFromInsert() {
        setPrimitiveValue(Int16.min, forKey: "sortOrder")
    }
}
