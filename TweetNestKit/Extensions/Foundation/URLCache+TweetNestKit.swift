//
//  URLCache+TweetNestKit.swift
//  URLCache+TweetNestKit
//
//  Created by Jaehong Kang on 2021/09/03.
//

import Foundation

extension URLCache {
    public static let twnk_shared: URLCache = URLCache(
        memoryCapacity: URLCache.shared.memoryCapacity,
        diskCapacity: 512*1024*1024,
        directory: Session.containerCacheURL
    )
}
