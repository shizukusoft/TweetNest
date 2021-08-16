//
//  DeleteBulkTweetsView.swift
//  DeleteBulkTweetsView
//
//  Created by Jaehong Kang on 2021/08/15.
//

import SwiftUI
import Twitter
import TweetNestKit
import UnifiedLogging
import OrderedCollections

struct DeleteBulkTweetsView: View {
    @Environment(\.account) private var account: TweetNestKit.Account?
    
    let tweets: OrderedSet<Tweet>
    
    private let leastTweetDate: Date
    private let greatestTweetDate: Date
    
    @Binding var isPresented: Bool
    
    @State var targetTweets: [Tweet]
    
    @State var sinceDate: Date
    @State var untilDate: Date
    
    @State var showConfirmAlert: Bool = false
    
    @State var progress: (value: Double, total: Double)? = nil
    
    @State var showError: Bool = false
    @State var error: TweetNestError? = nil
    
    var body: some View {
        ZStack {
            if let progress = progress {
                ProgressView(value: progress.value, total: progress.total) {
                    Text("Deleting...")
                }
                .progressViewStyle(.linear)
                .padding(16)
                .interactiveDismissDisabled(true)
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                .alert(isPresented: $showError, error: error) { _ in
                    isPresented = false
                }
                .zIndex(1)
            } else {
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
                                Task {
                                    await delete()
                                }
                            } label: {
                                Text("Delete")
                            }
                        } message: {
                            Text("\(targetTweets.count.formatted()) tweets will be deleted.")
                        }
                    }
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                .zIndex(-1)
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
    
    private func delete() async {
        guard let account = account else {
            return
        }
        
        let targetTweets = targetTweets
        
        withAnimation {
            progress = (value: 0, total: Double(targetTweets.count))
        }
        
        let task = Task.detached {
            try await withThrowingTaskGroup(of: Void.self) { taskGroup in
                for tweet in targetTweets {
                    taskGroup.addTask {
                        try await tweet.delete(session: .session(for: account))
                    }
                }
                
                var deletedCount: Double = 0
                
                for try await _ in taskGroup {
                    deletedCount += 1
                    progress = (value: deletedCount, total: Double(targetTweets.count))
                }
            }
        }
        
        #if os(iOS)
        let backgroundTaskIdentifier = await UIApplication.shared.beginBackgroundTask {
            task.cancel()
        }
        #endif
        
        do {
            _ = try await task.value

            isPresented = false
        } catch {
            Logger().error("Error occurred: \(String(reflecting: error), privacy: .public)")
            self.error = TweetNestError(error)
            showError = true
        }

        #if os(iOS)
        await UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
        #endif
    }
    
}

struct DeleteBulkTweetsView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteBulkTweetsView(tweets: [], isPresented: .constant(true))
    }
}
