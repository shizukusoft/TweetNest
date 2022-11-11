//
//  BatchDeleteTweetsFormView.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/09/19.
//

import SwiftUI
import OrderedCollections
import TweetNestKit
import Twitter

struct BatchDeleteTweetsFormView: View {
    let sourceTweets: OrderedDictionary<Tweet.ID, Tweet>
    @Binding var targetTweets: OrderedDictionary<Tweet.ID, Tweet>
    @Binding var isBatchDeletionStarted: Bool

    private let leastTweetDate: Date
    private let greatestTweetDate: Date

    @State private var includesTweets: Bool = true
    @State private var includesRetweets: Bool = true

    @State private var sinceDate: Date
    @State private var untilDate: Date

    @State private var showConfirmAlert: Bool = false

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Loaded Tweets")
                    Spacer()
                    Text(sourceTweets.count.twnk_formatted())
                }
            }

            Section {
                #if !os(watchOS)
                DatePicker(selection: $sinceDate, in: leastTweetDate...greatestTweetDate, displayedComponents: [.date]) {
                    Text("Since")
                }
                .onChange(of: sinceDate) { newValue in
                    if !(leastTweetDate...untilDate).contains(newValue) {
                        withAnimation {
                            untilDate = greatestTweetDate
                        }
                    }

                    updateTargetTweets()
                }

                DatePicker(selection: $untilDate, in: leastTweetDate...greatestTweetDate, displayedComponents: [.date]) {
                    Text("Until")
                }
                .onChange(of: untilDate) { newValue in
                    if !(sinceDate...greatestTweetDate).contains(newValue) {
                        withAnimation {
                            sinceDate = leastTweetDate
                        }
                    }

                    updateTargetTweets()
                }
                #endif

                Toggle("Tweets", isOn: $includesTweets)
                    .onChange(of: includesTweets) { _ in updateTargetTweets() }

                Toggle("Retweets", isOn: $includesRetweets)
                    .onChange(of: includesRetweets) { _ in updateTargetTweets() }
            }

            Section {
                HStack {
                    Text("Target Tweets")
                    Spacer()
                    Text(targetTweets.count.twnk_formatted())
                }
            }

            Section {
                Button(role: .destructive) {
                    showConfirmAlert = true
                } label: {
                    Text("Delete")
                }
                .disabled(targetTweets.count <= 0)
            }
        }
        .onAppear {
            updateTargetTweets()
        }
        .alert(Text("Delete Tweets?"), isPresented: $showConfirmAlert) {
            Button(role: .cancel) {

            } label: {
                Text("Cancel")
            }

            Button(role: .destructive) {
                withAnimation {
                    isBatchDeletionStarted = true
                }
            } label: {
                Text("Delete")
            }
        } message: {
            Text("\(targetTweets.count.twnk_formatted()) tweets will be deleted.")
        }
    }

    init(
        sourceTweets: OrderedDictionary<Tweet.ID, Tweet>,
        targetTweets: Binding<OrderedDictionary<Tweet.ID, Tweet>>,
        isBatchDeletionStarted: Binding<Bool>
    ) {
        self.sourceTweets = sourceTweets
        self._targetTweets = targetTweets
        self._isBatchDeletionStarted = isBatchDeletionStarted

        let sortedTweets = sourceTweets.values.sorted { $0.createdAt < $1.createdAt }

        leastTweetDate = sortedTweets.first?.createdAt ?? Date()
        greatestTweetDate = sortedTweets.last?.createdAt ?? Date()

        _sinceDate = State(initialValue: leastTweetDate)
        _untilDate = State(initialValue: greatestTweetDate)
    }

    private func updateTargetTweets() {
        let calendar = Calendar.current

        let sinceDate = calendar.startOfDay(for: sinceDate)
        let untilDate = untilDate
        let nextUntilDate = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: untilDate))

        self.targetTweets = OrderedDictionary(
            uniqueKeysWithValues: sourceTweets
                .lazy
                .filter {
                    if let nextUntilDate = nextUntilDate {
                        return (sinceDate..<nextUntilDate).contains($0.value.createdAt)
                    } else {
                        return (sinceDate...untilDate).contains($0.value.createdAt)
                    }
                }
                .filter {
                    if $0.value.text.starts(with: "RT @") { // Twitter Archive Does (assets/js/ondemand.App.{hash}.js)
                        return includesRetweets
                    } else {
                        return includesTweets
                    }
                }
        )
    }
}

struct BatchDeleteTweetsFormView_Previews: PreviewProvider {
    static var previews: some View {
        BatchDeleteTweetsFormView(sourceTweets: [:], targetTweets: .constant([:]), isBatchDeletionStarted: .constant(false))
    }
}
