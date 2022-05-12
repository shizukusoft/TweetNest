//
//  ManagedUser+CoreDataClass.swift
//  TweetNestKit
//
//  Created by 강재홍 on 2022/05/03.
//
//

import Foundation
import CoreData


public class ManagedUser: NSManagedObject {

}

extension ManagedUser {
    @NSManaged public private(set) var accounts: [ManagedAccount]? // The accessor of the accounts property.
    @NSManaged public private(set) var userDetails: [ManagedUserDetail]? // The accessor of the userDetails property.
}
