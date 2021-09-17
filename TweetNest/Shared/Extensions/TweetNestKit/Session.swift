//
//  TweetNestKit.Session.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/02/23.
//

import Foundation
import TweetNestKit

extension TweetNestKit.Session {
    public static let preview: Session = Session(inMemory: true)
}

extension TweetNestKit.Account {
    public static var preview: Account {
        let fetchRequest = Account.fetchRequest()

        return try! Session.preview.persistentContainer.viewContext.fetch(fetchRequest)[0]
    }
}
