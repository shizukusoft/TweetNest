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
    
    let tweets: OrderedSet<Tweet>
    
    private let leastTweetDate: Date
    private let greatestTweetDate: Date
    
    @Binding var isPresented: Bool
    
    @State var targetTweets: [Tweet]
    
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
                        DeleteBulkTweetsView(isPresented: $isPresented, targetTweets: targetTweets)
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
                                    Text(tweets.count.formatted())
                                }
                            }
                            Section {
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
                            }
                            Section {
                                HStack {
                                    Text("Target Tweets")
                                    Spacer()
                                    Text(targetTweets.count.formatted())
                                }
                            }
                            Section {
                                Button(role: .destructive) {
                                    showConfirmAlert = true
                                } label: {
                                    Text("Delete")
                                }
                                .disabled(targetTweets.count <= 0)
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
                                    Text("\(targetTweets.count.formatted()) tweets will be deleted.")
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
        .navigationBarBackButtonHidden(true)
    }
    
    init(tweets: [Tweet], isPresented: Binding<Bool>) {
        let tweets = OrderedSet(tweets)
        
        self.tweets = tweets
        _targetTweets = State(initialValue: Array(tweets))
        _isPresented = isPresented
        
        let sortedTweets = tweets.sorted { $0.createdAt < $1.createdAt }
        
        leastTweetDate = sortedTweets.first?.createdAt ?? Date()
        greatestTweetDate = sortedTweets.last?.createdAt ?? Date()
        
        _sinceDate = State(initialValue: leastTweetDate)
        _untilDate = State(initialValue: greatestTweetDate)
    }
    
    private func updateTargetTweets() {
        self.targetTweets = tweets
            .lazy
            .filter { $0.createdAt >= sinceDate }
            .filter { $0.createdAt <= untilDate }
    }
}

struct DeleteBulkTweetsFormView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteBulkTweetsFormView(tweets: [], isPresented: .constant(true))
    }
}
