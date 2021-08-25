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
        let urlSessionConfiguration = URLSessionConfiguration.twt_default
        urlSessionConfiguration.httpCookieStorage = nil
        urlSessionConfiguration.httpShouldSetCookies = false
        urlSessionConfiguration.httpCookieAcceptPolicy = .never
        
        urlSessionConfiguration.urlCredentialStorage = nil
        
        urlSessionConfiguration.sharedContainerIdentifier = Session.applicationGroupIdentifier
        
        self.init(consumerKey: twitterAPIConfiguration.apiKey, consumerSecret: twitterAPIConfiguration.apiKeySecret, urlSessionConfiguration: urlSessionConfiguration)
    }
}

extension Twitter.Session {
    public static func session(for account: Account, session: Session = .shared) async throws -> Twitter.Session {
        try await session.twitterSession(for: account.objectID)
    }
}
