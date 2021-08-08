//
//  URLSessionConfiguration+TweetNestKit.swift
//  URLSessionConfiguration+TweetNestKit
//
//  Created by Jaehong Kang on 2021/08/08.
//

import Foundation

extension URLSessionConfiguration {
    public static var twnk_default: URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default

        configuration.sharedContainerIdentifier = Session.applicationGroupIdentifier

        return configuration
    }
}
