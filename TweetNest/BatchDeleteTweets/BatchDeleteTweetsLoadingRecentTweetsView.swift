//
//  BatchDeleteTweetsLoadingRecentTweetsView.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/09/19.
//

import SwiftUI
import OrderedCollections
import TweetNestKit
import Twitter

struct BatchDeleteTweetsLoadingRecentTweetsView: View {
    @Environment(\.account) private var account: ManagedAccount?

    @Binding var sourceTweets: OrderedDictionary<Tweet.ID, Tweet>?

    @State private var showError: Bool = false
    @State private var error: TweetNestError?

    @MainActor
    private var accountUserID: String? {
        account?.userID
    }

    @MainActor
    private var twitterSession: Twitter.Session? {
        get async throws {
            guard let account = account else { return nil }

            return try await .session(for: account, session: TweetNestApp.session)
        }
    }

    var body: some View {
        ProgressView("Loading Recent Tweets…")
            .task {
                await fetchTweets()
            }
            .alert(isPresented: $showError, error: error)
    }

    func fetchTweets() async {
        do {
            guard
                let accountUserID = await accountUserID,
                let twitterSession = try await twitterSession
            else {
                return
            }

            let tweets: OrderedDictionary<Tweet.ID, [Tweet]> = OrderedDictionary(
                grouping: try await User.tweets(forUserID: accountUserID, session: twitterSession).tweets
            ) { $0.id }

            withAnimation {
                self.sourceTweets = tweets.compactMapValues { $0.last }
            }
        } catch {
            self.error = TweetNestError(error)
            showError = true
        }
    }
}

struct BatchDeleteTweetsLoadingRecentTweetsView_Previews: PreviewProvider {
    static var previews: some View {
        BatchDeleteTweetsLoadingRecentTweetsView(sourceTweets: .constant(nil))
    }
}
