//
//  URLSessionConfiguration+TweetNestKit.swift
//  URLSessionConfiguration+TweetNestKit
//
//  Created by Jaehong Kang on 2021/08/08.
//

import Foundation
import Twitter

extension URLSessionConfiguration {
    public static var twnk_default: URLSessionConfiguration {
        let urlSessionConfiguration = URLSessionConfiguration.twt_default
        urlSessionConfiguration.httpCookieStorage = nil
        urlSessionConfiguration.httpShouldSetCookies = false
        urlSessionConfiguration.httpCookieAcceptPolicy = .never

        urlSessionConfiguration.urlCredentialStorage = nil

        urlSessionConfiguration.urlCache = .twnk_shared

        urlSessionConfiguration.sharedContainerIdentifier = Session.applicationGroupIdentifier

        urlSessionConfiguration.shouldUseExtendedBackgroundIdleMode = true

        #if os(iOS)
        urlSessionConfiguration.multipathServiceType = .handover
        #endif

        urlSessionConfiguration.timeoutIntervalForRequest = 15

        return urlSessionConfiguration
    }
}
