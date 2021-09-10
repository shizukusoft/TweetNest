//
//  DeleteBulkTweetsFormView.swift
//  DeleteBulkTweetsFormView
//
//  Created by Jaehong Kang on 2021/08/15.
//

import SwiftUI
import Twitter
import TweetNestKit
import UnifiedLogging
import OrderedCollections

struct DeleteBulkTweetsFormView: View {
    @Environment(\.account) private var account: TweetNestKit.Account?
    
    let tweets: OrderedDictionary<Tweet.ID, Tweet>
    
    private let leastTweetDate: Date
    private let greatestTweetDate: Date
    
    @Binding var isPresented: Bool

    @State var targetTweetIDs: [Tweet.ID]

    @State var includesTweets: Bool = true
    @State var includesRetweets: Bool = true
    
    @State var sinceDate: Date
    @State var untilDate: Date
    
    @State var showConfirmAlert: Bool = false
    
    @State var isInProgress: Bool = false
    
    var body: some View {
        ZStack {
            if isInProgress {
                Rectangle()
                    .foregroundColor(.clear)
                    .overlay {
                        DeleteBulkTweetsView(isPresented: $isPresented, targetTweetIDs: OrderedSet(targetTweetIDs))
                    }
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                    .zIndex(2)
            } else {
                Rectangle()
                    .foregroundColor(.clear)
                    .overlay {
                        Form {
                            Section {
                                HStack {
                                    Text("Loaded Tweets")
                                    Spacer()
                                    Text(tweets.count.twnk_formatted())
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
                                    
                                    updateTargetTweetIDs()
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
                                    
                                    updateTargetTweetIDs()
                                }
                                #endif

                                Toggle(String(localized: "Tweets"), isOn: $includesTweets)
                                    .onChange(of: includesTweets) { _ in updateTargetTweetIDs() }

                                Toggle(String(localized: "Retweets"), isOn: $includesRetweets)
                                    .onChange(of: includesRetweets) { _ in updateTargetTweetIDs() }
                            }

                            Section {
                                HStack {
                                    Text("Target Tweets")
                                    Spacer()
                                    Text(targetTweetIDs.count.twnk_formatted())
                                }
                            }
                        }
                        .toolbar {
                            ToolbarItemGroup(placement: .cancellationAction) {
                                Button(role: .cancel) {
                                    isPresented = false
                                } label: {
                                    Text("Cancel")
                                }
                            }

                            ToolbarItemGroup(placement: .destructiveAction) {
                                Button(role: .destructive) {
                                    showConfirmAlert = true
                                } label: {
                                    Text("Delete")
                                }
                                .disabled(targetTweetIDs.count <= 0)
                                .alert(Text("Delete Tweets?"), isPresented: $showConfirmAlert) {
                                    Button(role: .cancel) {

                                    } label: {
                                        Text("Cancel")
                                    }

                                    Button(role: .destructive) {
                                        isInProgress = true
                                    } label: {
                                        Text("Delete")
                                    }
                                } message: {
                                    Text("\(targetTweetIDs.count.twnk_formatted()) tweets will be deleted.")
                                }
                            }
                        }
                    }
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                    .zIndex(1)
            }
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .navigationTitle(Text("Delete Tweets"))
    }
    
    init(tweets: [Tweet], isPresented: Binding<Bool>) {
        let tweets: OrderedDictionary<Tweet.ID, Tweet> = OrderedDictionary<Tweet.ID, [Tweet]>(grouping: tweets, by: \.id)
            .compactMapValues { $0.last }

        self.tweets = tweets
        _targetTweetIDs = State(initialValue: Array(tweets.keys))
        _isPresented = isPresented
        
        let sortedTweets = tweets.values.sorted { $0.createdAt < $1.createdAt }
        
        leastTweetDate = sortedTweets.first?.createdAt ?? Date()
        greatestTweetDate = sortedTweets.last?.createdAt ?? Date()
        
        _sinceDate = State(initialValue: leastTweetDate)
        _untilDate = State(initialValue: greatestTweetDate)
    }
    
    private func updateTargetTweetIDs() {
        self.targetTweetIDs = tweets
            .lazy
            .filter { $0.value.createdAt >= sinceDate }
            .filter { $0.value.createdAt <= untilDate.addingTimeInterval(60 * 60 * 24 - 1) }
            .filter {
                if $0.value.text.starts(with: "RT @") { // Twitter Archive Does (assets/js/ondemand.App.{hash}.js)
                    return includesRetweets
                } else {
                    return includesTweets
                }
            }
            .map { $0.key }
    }
}

struct DeleteBulkTweetsFormView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteBulkTweetsFormView(tweets: [], isPresented: .constant(true))
    }
}
