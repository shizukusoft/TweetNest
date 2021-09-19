//
//  Session.swift
//  Session
//
//  Created by Jaehong Kang on 2021/08/15.
//

import Foundation
import Twitter

extension Twitter.Session {
    convenience init(twitterAPIConfiguration: Session.TwitterAPIConfiguration) {
        self.init(consumerKey: twitterAPIConfiguration.apiKey, consumerSecret: twitterAPIConfiguration.apiKeySecret, urlSessionConfiguration: .twnk_default)
    }
}

extension Twitter.Session {
    public static func session(for account: Account, session: Session) async throws -> Twitter.Session {
        try await session.twitterSession(for: account.objectID)
    }
}
