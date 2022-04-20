//
//  SessionActor.swift
//  TweetNestKit
//
//  Created by 강재홍 on 2022/04/20.
//

import Foundation
import CoreData
import Twitter

actor SessionActor {
    unowned let session: Session

    var twitterSessions = [URL: Twitter.Session]()

    init(session: Session) {
        self.session = session
    }

    func twitterSession(for accountObjectID: NSManagedObjectID? = nil) async throws -> Twitter.Session {
        let twitterAPIConfiguration = try await session.twitterAPIConfiguration

        guard let accountObjectID = accountObjectID, accountObjectID.isTemporaryID == false else {
            return Twitter.Session(consumerKey: twitterAPIConfiguration.apiKey, consumerSecret: twitterAPIConfiguration.apiKeySecret)
        }

        guard let twitterSession: Twitter.Session = twitterSessions[accountObjectID.uriRepresentation()] else {
            let twitterSession = Twitter.Session(twitterAPIConfiguration: twitterAPIConfiguration)
            updateTwitterSession(twitterSession, for: accountObjectID)

            try await twitterSession.updateCredential(session.credential(for: accountObjectID))

            return twitterSession
        }

        return twitterSession
    }

    func updateTwitterSession(_ twitterSession: Twitter.Session?, for accountObjectID: NSManagedObjectID) {
        guard accountObjectID.isTemporaryID == false else {
            return
        }

        twitterSessions[accountObjectID.uriRepresentation()] = twitterSession
    }
}
