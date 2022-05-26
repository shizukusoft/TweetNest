//
//  ManagedAccount+Preview.swift
//  TweetNest
//
//  Created by Mina Her on 2022/05/18.
//

#if DEBUG
import Foundation
import TweetNestKit

extension TweetNestKit.ManagedAccount {

    @usableFromInline
    static var preview: ManagedAccount {
        let fetchRequest = ManagedAccount.fetchRequest()
        do {
            return try Session.preview.persistentContainer.viewContext.fetch(fetchRequest)[0]
        } catch let error as NSError {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    }
}
#endif
