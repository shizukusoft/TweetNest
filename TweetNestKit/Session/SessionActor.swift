//
//  SessionActor.swift
//  TweetNestKit
//
//  Created by 강재홍 on 2022/04/20.
//

import Foundation
import CoreData
import Twitter
import UnifiedLogging

actor SessionActor {
    unowned let session: Session

    var twitterSessions = [URL: Twitter.Session]()

    var fetchNewDataTimer: DispatchSourceTimer? = nil {
        willSet {
            guard fetchNewDataTimer !== newValue else { return }

            fetchNewDataTimer?.cancel()
        }
        didSet {
            guard fetchNewDataTimer !== oldValue else { return }

            fetchNewDataTimer?.activate()
        }
    }

    init(session: Session) {
        self.session = session
    }
}

extension SessionActor {
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

extension SessionActor {
    func initializeFetchNewDataTimer(interval: TimeInterval) {
        let newFetchNewDataTimer = DispatchSource.makeTimerSource(queue: .global(qos: .utility))
        newFetchNewDataTimer.setEventHandler { [session] in
            Task {
                do {
                    try await session.fetchNewData()
                } catch {
                    Logger(label: Bundle.tweetNestKit.bundleIdentifier!, category: String(reflecting: Self.self))
                        .error("Error occurred fetch new data: \(error as NSError, privacy: .public)")
                }
            }
        }
        newFetchNewDataTimer.schedule(deadline: .now() + interval, repeating: interval, leeway: .seconds(30))

        self.fetchNewDataTimer = newFetchNewDataTimer
    }

    func destroyFetchNewDataTimer() {
        self.fetchNewDataTimer = nil
    }

    func updateFetchNewDataTimer(interval: TimeInterval) {
        guard fetchNewDataTimer != nil else {
            return
        }

        initializeFetchNewDataTimer(interval: interval)
    }
}
