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

        urlSessionConfiguration.reset()

        return urlSessionConfiguration
    }

    public static func twnk_background(withIdentifier identifier: String) -> URLSessionConfiguration {
        let urlSessionConfiguration = URLSessionConfiguration.background(withIdentifier: identifier)

        urlSessionConfiguration.isDiscretionary = true
        urlSessionConfiguration.sessionSendsLaunchEvents = true

        urlSessionConfiguration.reset()

        return urlSessionConfiguration
    }

    private func reset() {
        httpCookieStorage = nil
        httpShouldSetCookies = false
        httpCookieAcceptPolicy = .never

        urlCredentialStorage = nil

        urlCache = .twnk_shared

        sharedContainerIdentifier = Session.applicationGroupIdentifier

        shouldUseExtendedBackgroundIdleMode = true

        #if os(iOS)
        multipathServiceType = .handover
        #endif

        timeoutIntervalForRequest = 15
    }
}
