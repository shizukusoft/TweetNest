//
//  Array+TweetNestKit.swift
//  Array+TweetNestKit
//
//  Created by Jaehong Kang on 2021/08/08.
//

import Foundation

extension Collection where Index == Int {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
