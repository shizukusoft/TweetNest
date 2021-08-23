//
//  Account.swift
//  Account
//
//  Created by Mina Her on 2021/08/23.
//

import TweetNestKit

extension Account {

    var usernameOrID: String {
        user?.sortedUserDetails?.last?.username ?? "#\(id.formatted())"
    }
}
