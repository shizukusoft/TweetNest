//
//  Bundle+TweetNestKit.swift
//  Bundle+TweetNestKit
//
//  Created by Jaehong Kang on 2021/08/05.
//

import Foundation

extension Bundle {
    private class `_` {}

    class var tweetNestKit: Self {
        self.init(for: `_`.self)
    }
}

extension Bundle {
    public var name: String? {
        infoDictionary?["CFBundleName"] as? String
    }
}
