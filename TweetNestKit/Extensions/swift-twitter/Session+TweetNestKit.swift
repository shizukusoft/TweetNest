//
//  Session.swift
//  Session
//
//  Created by Jaehong Kang on 2021/08/15.
//

import Foundation
import Twitter

extension Twitter.Session {
    public static func session(for account: Account, session: Session = .shared) async throws -> Twitter.Session {
        try await session.twitterSession(for: account.id)
    }
}
