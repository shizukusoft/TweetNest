//
//  ManagedAccountV2+CoreDataClass.swift
//  TweetNestKit
//
//  Created by 강재홍 on 2022/05/02.
//
//

import Foundation
import CoreData
import Twitter

public class ManagedAccountV2: NSManagedObject { }

extension ManagedAccountV2 {
    @NSManaged public private(set) var users: [User]? // The accessor of the users property.
}

extension ManagedAccountV2 {
    var credential: Twitter.Session.Credential? {
        guard
            let token = token,
            let tokenSecret = tokenSecret
        else {
            return nil
        }

        return Twitter.Session.Credential(token: token, tokenSecret: tokenSecret)
    }
}
