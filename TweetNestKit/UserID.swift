//
//  UserID.swift
//  TweetNestKit
//
//  Created by 강재홍 on 2022/04/17.
//

import Foundation

public protocol UserID {
    var displayUserID: String { get }
}

extension Int64: UserID {
    public var displayUserID: String {
        "#\(self.twnk_formatted())"
    }
}

extension String: UserID {
    public var displayUserID: String {
        Int64(self)?.displayUserID ?? "#\(self)"
    }
}
