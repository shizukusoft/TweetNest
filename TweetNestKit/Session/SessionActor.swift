//
//  SessionActor.swift
//  TweetNestKit
//
//  Created by 강재홍 on 2022/04/20.
//

import Foundation
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
    func run<T>(resultType: T.Type = T.self, body: @Sendable (isolated SessionActor) async throws -> T) async rethrows -> T where T : Sendable {
        try await body(self)
    }
}

extension SessionActor {
    func twitterSession(for url: URL) -> Twitter.Session? {
        twitterSessions[url]
    }

    func updateTwitterSession(_ twitterSession: Twitter.Session?, for url: URL) {
        twitterSessions[url] = twitterSession
    }
}

extension SessionActor {
    func initializeFetchNewDataTimer(interval: TimeInterval) {
        guard interval > 0 else {
            self.fetchNewDataTimer = nil
            return
        }

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
