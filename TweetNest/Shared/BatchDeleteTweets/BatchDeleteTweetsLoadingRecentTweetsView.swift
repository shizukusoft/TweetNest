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
    @Environment(\.session) private var session: TweetNestKit.Session
    @Environment(\.account) private var account: TweetNestKit.Account?

    @Binding var sourceTweets: OrderedDictionary<Tweet.ID, Tweet>?

    @State private var showError: Bool = false
    @State private var error: TweetNestError?

    var body: some View {
        ProgressView("Loading Recent Tweets…")
            .task {
                await fetchTweets()
            }
            .alert(isPresented: $showError, error: error)
    }

    @MainActor
    func fetchTweets() async {
        guard
            let account = account,
            let userID = account.userID
        else {
            return
        }

        do {
            let tweets: OrderedDictionary<Tweet.ID, [Tweet]> = OrderedDictionary(
                grouping: try await User.tweets(forUserID: userID, session: .session(for: account, session: session)).compactMap { try? $0.get() }
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
