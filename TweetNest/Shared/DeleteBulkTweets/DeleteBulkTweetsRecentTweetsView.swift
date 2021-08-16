//
//  DeleteBulkTweetsRecentTweetsView.swift
//  DeleteBulkTweetsRecentTweetsView
//
//  Created by Jaehong Kang on 2021/08/15.
//

import SwiftUI
import TweetNestKit
import Twitter

struct DeleteBulkTweetsRecentTweetsView: View {
    let account: TweetNestKit.Account
    
    @Binding var isPresented: Bool
    
    @State var tweets: [Tweet]? = nil
    
    @State var showError: Bool = false
    @State var error: TweetNestError? = nil
    
    var body: some View {
        ZStack {
            if let tweets = tweets {
                DeleteBulkTweetsView(tweets: tweets, isPresented: $isPresented)
                    .environment(\.account, account)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            } else {
                ProgressView("Loading Recent Tweets...")
                    .task {
                        await fetchTweets()
                    }
                    .alert(isPresented: $showError, error: error)
            }
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .navigationTitle(Text("Delete Tweets"))
        .navigationBarBackButtonHidden(true)
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
    
    func fetchTweets() async {
        guard let userID = account.user?.id else {
            return
        }
        
        do {
            let tweets = try await User.tweets(forUserID: userID, session: .session(for: account))
                .map { try $0.get() }

            withAnimation {
                self.tweets = tweets
            }
        } catch {
            self.error = TweetNestError(error)
            showError = true
        }
    }
}

struct DeleteBulkTweetsRecentTweetsView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteBulkTweetsRecentTweetsView(account: .preview, isPresented: .constant(true))
    }
}
