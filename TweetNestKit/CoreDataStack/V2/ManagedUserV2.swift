//
//  ManagedUserV2+CoreDataClass.swift
//  TweetNestKit
//
//  Created by 강재홍 on 2022/05/02.
//
//

import Foundation
import CoreData


public class ManagedUserV2: NSManagedObject { }

extension ManagedUserV2 {
    @NSManaged public private(set) var accounts: [Account]? // The accessor of the accounts property.
    @NSManaged public private(set) var userDetails: [UserDetail]? // The accessor of the userDetails property.
}
