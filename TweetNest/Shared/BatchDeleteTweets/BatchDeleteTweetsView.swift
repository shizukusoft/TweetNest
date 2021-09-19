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
                    .zIndex(1)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                } else {
                    BatchDeleteTweetsProgressView(
                        targetTweets: targetTweets,
                        isBatchDeletionExecuting: $isBatchDeletionExecuting,
                        isBatchDeletionFinished: $isBatchDeletionFinished
                    )
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
        .navigationTitle(Text("Delete Tweets"))
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
