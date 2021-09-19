//
//  BatchDeleteTweetsView.swift
//  TweetNest (iOS)
//
//  Created by Jaehong Kang on 2021/09/19.
//

import SwiftUI
import OrderedCollections
import TweetNestKit
import Twitter

struct BatchDeleteTweetsView: View {
    @Binding var isPresented: Bool

    let account: TweetNestKit.Account?

    enum Source {
        case recentTweets
        case twitterArchive
    }
    let source: Source

    @State private var sourceTweets: OrderedDictionary<Tweet.ID, Tweet>?
    @State private var targetTweets: OrderedDictionary<Tweet.ID, Tweet> = [:]
    @State private var isBatchDeletionStarted: Bool = false
    @State private var isBatchDeletionExecuting: Bool = false
    @State private var isBatchDeletionFinished: Bool = false

    var body: some View {
        ZStack {
            if let sourceTweets = sourceTweets {
                if isBatchDeletionStarted == false {
                    BatchDeleteTweetsFormView(
                        sourceTweets: sourceTweets,
                        targetTweets: $targetTweets,
                        isBatchDeletionStarted: $isBatchDeletionStarted
                    )
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                } else {
                    BatchDeleteTweetsProgressView(
                        targetTweets: targetTweets,
                        isBatchDeletionExecuting: $isBatchDeletionExecuting,
                        isBatchDeletionFinished: $isBatchDeletionFinished
                    )
                    .zIndex(-1)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                }
            } else {
                Group {
                    switch source {
                    case .recentTweets:
                        BatchDeleteTweetsLoadingRecentTweetsView(sourceTweets: $sourceTweets)
                    case .twitterArchive:
                        #if canImport(JavaScriptCore)
                        BatchDeleteTweetsLoadingTwitterArchiveView(sourceTweets: $sourceTweets)
                        #else
                        fatalError("twitterArchive is not supported.")
                        #endif
                    }
                }
                .zIndex(-1)
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            }
        }
        .environment(\.account, account)
        .navigationTitle("Delete Tweets")
        .toolbar {
            ToolbarItemGroup(placement: .cancellationAction) {
                if isBatchDeletionFinished == false {
                    Button(role: .cancel) {
                        isPresented = false
                    } label: {
                        Text("Cancel")
                    }
                }
            }

            ToolbarItemGroup(placement: .confirmationAction) {
                if isBatchDeletionFinished {
                    Button {
                        isPresented = false
                    } label: {
                        Text("Done")
                    }
                }
            }
        }
        .interactiveDismissDisabled(isBatchDeletionExecuting)
        .onChange(of: sourceTweets) { newValue in
            targetTweets = newValue ?? [:]
        }
        #if DEBUG
        .onAppear {
            if CommandLine.arguments.contains("-com.tweetnest.TweetNest.Preview") {
                sourceTweets = OrderedDictionary<Tweet.ID, [Tweet]>(
                    grouping: (0..<39042).compactMap { id in
                        return #"""
                        {
                          "retweeted" : false,
                          "source" : "<a href=\"http://twitter.com/download/iphone\" rel=\"nofollow\">Twitter for iPhone</a>",
                          "entities" : {
                            "hashtags" : [ ],
                            "symbols" : [ ],
                            "user_mentions" : [ ],
                            "urls" : [ ]
                          },
                          "favorite_count" : "0",
                          "id_str" : "\#(-id)",
                          "truncated" : false,
                          "retweet_count" : "0",
                          "id" : "\#(-id)",
                          "created_at" : "Fri Apr 02 07:22:44 +0000 2021",
                          "favorited" : false,
                          "full_text" : "Preview Text",
                          "lang" : "en"
                        }
                        """#
                        .data(using: .utf8)
                        .flatMap {
                            try? JSONDecoder.twt_default.decode(Tweet.self, from: $0)
                        }
                    }
                ) { $0.id }
                .compactMapValues { $0.last }
            }
        }
        #endif
    }
}

struct BatchDeleteTweetsView_Previews: PreviewProvider {
    static var previews: some View {
        BatchDeleteTweetsView(isPresented: .constant(true), account: nil, source: .recentTweets)

        #if canImport(JavaScriptCore)
        BatchDeleteTweetsView(isPresented: .constant(true), account: nil, source: .twitterArchive)
        #endif
    }
}
