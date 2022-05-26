//
//  ManagedUser+Preview.swift
//  TweetNest
//
//  Created by Mina Her on 2022/05/19.
//

#if DEBUG
import Foundation
import TweetNestKit

extension TweetNestKit.ManagedUser {

    @inlinable
    static var preview: ManagedUser {
        previews.first!
    }

    @inlinable
    static var previews: [ManagedUser] {
        ManagedAccount.preview.users!
    }
}
#endif
