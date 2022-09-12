//
//  ManagedAccount+Preview.swift
//  TweetNest
//
//  Created by Mina Her on 2022/05/18.
//

import Foundation
import TweetNestKit

extension TweetNestKit.ManagedAccount {

    @usableFromInline
    static var preview: ManagedAccount {
        let fetchRequest = ManagedAccount.fetchRequest()
        do {
            return try SessionEnvironmentKey.defaultValue.persistentContainer.viewContext.fetch(fetchRequest).randomElement()!
        } catch let error as NSError {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    }
}
