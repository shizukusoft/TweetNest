//
//  Session.swift
//  Session
//
//  Created by Jaehong Kang on 2021/08/15.
//

import Foundation
import Twitter

extension Twitter.Session {
    private static var urlSessionConfiguration: URLSessionConfiguration {
        let urlSessionConfiguration = URLSessionConfiguration.twnk_default

        urlSessionConfiguration.networkServiceType = .responsiveData

        #if os(iOS)
        urlSessionConfiguration.multipathServiceType = .interactive
        #endif

        return urlSessionConfiguration
    }

    convenience init(twitterAPIConfiguration: Session.TwitterAPIConfiguration) {
        self.init(consumerKey: twitterAPIConfiguration.apiKey, consumerSecret: twitterAPIConfiguration.apiKeySecret, urlSessionConfiguration: Self.urlSessionConfiguration)
    }
}

extension Twitter.Session {
    public static func session(for account: ManagedAccount, session: Session) async throws -> Twitter.Session {
        try await session.twitterSession(for: account.objectID)
    }
}
