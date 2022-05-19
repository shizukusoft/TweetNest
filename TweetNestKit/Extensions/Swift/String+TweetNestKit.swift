//
//  String+TweetNestKit.swift
//  TweetNestKit
//
//  Created by Jaehong Kang on 2022/05/19.
//

import Foundation

extension String {
    public init?<Root, Value>(twnk_keyPath keyPath: KeyPath<Root, Value>) {
        guard let keyPathString = keyPath._kvcKeyPathString else {
            return nil
        }

        self = keyPathString
    }
}
