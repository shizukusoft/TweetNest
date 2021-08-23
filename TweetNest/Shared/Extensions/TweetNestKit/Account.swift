//
//  Account.swift
//  Account
//
//  Created by Mina Her on 2021/08/23.
//

import TweetNestKit

extension Account {

    var usernameOrID: String {
        if let username = user?.sortedUserDetails?.last?.username {
            return "@\(username)"
        }
        return "#\(id.formatted())"
    }
}
