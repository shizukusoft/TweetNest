//
//  ManagedUserDataAsset+CoreDataClass.swift
//  TweetNestKit
//
//  Created by Jaehong Kang on 2022/05/03.
//
//

import Foundation
import CoreData
import CryptoKit

public class ManagedUserDataAsset: ManagedObject {
    public override func awakeFromInsert() {
        super.awakeFromInsert()

        setPrimitiveValue(Date(), forKey: (\ManagedUserDataAsset.creationDate)._kvcKeyPathString!)
    }
}
