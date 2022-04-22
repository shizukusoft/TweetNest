//
//  URLSessionConfiguration+TweetNestKit.swift
//  URLSessionConfiguration+TweetNestKit
//
//  Created by Jaehong Kang on 2021/08/08.
//

import Foundation
import OrderedCollections
import Twitter

extension URLSessionConfiguration {
    public static var twnk_default: URLSessionConfiguration {
        let urlSessionConfiguration = URLSessionConfiguration.default

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
        httpAdditionalHeaders = {
            var httpAdditionalHeaders = [AnyHashable : Any]()

            let preferredLanguages = OrderedSet(Locale.preferredLanguages.flatMap { [$0, $0.components(separatedBy: "-")[0]] } + ["*"])
            httpAdditionalHeaders["Accept-Language"] = preferredLanguages.qualityJoined

            return httpAdditionalHeaders
        }()

        timeoutIntervalForRequest = 15

        httpCookieAcceptPolicy = .never
        httpShouldSetCookies = false
        httpCookieStorage = nil

        urlCredentialStorage = nil

        urlCache = .twnk_shared

        sharedContainerIdentifier = Session.applicationGroupIdentifier

        shouldUseExtendedBackgroundIdleMode = true
    }
}

extension Collection where Element == String {
    fileprivate var qualityJoined: String {
        enumerated()
            .map { offset, value in
                let quality = 1.0 - ((Decimal(offset + 1)) / Decimal(count + 1))
                return "\(value);q=\(quality)"
            }
            .joined(separator: ", ")
    }
}
