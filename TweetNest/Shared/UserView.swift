//
//  UserView.swift
//  UserView
//
//  Created by Jaehong Kang on 2021/08/02.
//

import SwiftUI
import TweetNestKit
import UnifiedLogging

struct UserView: View {
    let user: User?
    
    var body: some View {
        if let user = user {
            ContentView(user: user)
        } else {
            EmptyView()
        }
    }
}

extension UserView {
    struct ContentView: View {
        @Environment(\.account) var account: Account?
        @ObservedObject var user: User

        var lastUserDetail: UserDetail? {
            user.sortedUserDetails?.last
        }

        @State var isRefreshing: Bool = false
        
        @State var showErrorAlert: Bool = false
        @State var error: TweetNestError? = nil

        #if os(iOS)
        @Environment(\.horizontalSizeClass) var horizontalSizeClass
        #endif

        var shouldCompactToolbar: Bool {
            #if os(iOS)
            return horizontalSizeClass == .compact
            #else
            return false
            #endif
        }
        
        #if os(iOS)
        @State var safariSheetURL: URL? = nil
        @State var shareSheetURL: URL? = nil
        #endif

        var userProfileURL: URL? {
            user.id.flatMap {
                URL(string: "https://twitter.com/intent/user?user_id=\($0)")!
            }
        }
        
        @State var showBulkDeleteRecentTweets: Bool = false
        @State var showBulkDeleteAllTweets: Bool = false
        
        @ViewBuilder
        var deleteMenu: some View {
            Menu {
                Button(role: .destructive) {
                    showBulkDeleteRecentTweets = true
                } label: {
                    Text("Delete Recent Tweets")
                }
                
                Button(role: .destructive) {
                    showBulkDeleteAllTweets = true
                } label: {
                    Text("Delete All Tweets")
                }
            } label: {
                Label {
                    Text("Delete")
                } icon: {
                    Image(systemName: "trash")
                }
            }
        }

        var body: some View {
            List {
                if let lastUserDetail = lastUserDetail {
                    Section {
                        UserDetailProfileView(userDetail: lastUserDetail)
                    } header: {
                        Text("Latest Profile")
                    } footer: {
                        VStack(alignment: .leading) {
                            user.id.flatMap { Text(verbatim: "#\(Int64($0)?.formatted() ?? $0)") }
                            if let lastUpdateDate = user.lastUpdateEndDate {
                                Text("Updated \(lastUpdateDate, style: .relative) ago")
                                .accessibilityAddTraits(.updatesFrequently)
                            }
                        }
                    }
                }
                UserAllDataSection(user: user)
            }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .navigationTitle(Text(verbatim: user.displayUsername))
            #if os(iOS)
            .refreshable(action: refresh)
            #endif
            .toolbar {
                ToolbarItemGroup(placement: .automatic) {
                    if shouldCompactToolbar {
                        Menu {
                            if let userProfileURL = userProfileURL {
                                Link(destination: userProfileURL) {
                                    Label(Text("Open Profile"), systemImage: "safari")
                                }

                                #if os(iOS)
                                Button {
                                    safariSheetURL = userProfileURL
                                } label: {
                                    Label(Text("Open Profile in Safari"), systemImage: "safari")
                                }
                                #endif
                            }
                            
                            #if os(iOS)
                            Divider()

                            Button(Label(Text("Share"), systemImage: "square.and.arrow.up")) {
                                shareSheetURL = userProfileURL
                            }
                            #endif
                            
                            if account != nil, account == user.account {
                                Divider()
                                
                                deleteMenu
                            }
                        } label: {
                            Label(Text("More"), systemImage: "ellipsis.circle")
                                .labelStyle(.iconOnly)
                        }
                    } else {
                        if let userProfileURL = userProfileURL {
                            Link(destination: userProfileURL) {
                                Label(Text("Open Profile"), systemImage: "safari")
                            }
                            #if os(iOS)
                            .contextMenu {
                                Link(destination: userProfileURL) {
                                    Label(Text("Open Profile"), systemImage: "safari")
                                }

                                Button {
                                    safariSheetURL = userProfileURL
                                } label: {
                                    Label(Text("Open Profile in Safari"), systemImage: "safari")
                                }
                            }
                            #endif
                            
                            #if os(iOS)
                            Button(Label(Text("Share"), systemImage: "square.and.arrow.up")) {
                                shareSheetURL = userProfileURL
                            }
                            #endif
                        }
                        
                        #if !os(iOS)
                        Button(Label(Text("Refresh"), systemImage: "arrow.clockwise")) {
                            Task {
                                refresh
                            }
                        }
                        .disabled(isRefreshing)
                        #endif
                        
                        if account != nil, account == user.account {
                            deleteMenu
                        }
                    }
                }
            }
            #if os(iOS)
            .sheet(item: $safariSheetURL) {
                SafariView(url: $0)
            }
            .sheet(item: $shareSheetURL) {
                ShareView(item: $0)
            }
            #endif
            .alert(isPresented: $showErrorAlert, error: error)
            .sheet(isPresented: $showBulkDeleteRecentTweets) {
                NavigationView {
                    if let account = account, account == user.account {
                        DeleteBulkTweetsRecentTweetsView(account: account, isPresented: $showBulkDeleteRecentTweets)
                    } else {
                        EmptyView()
                    }
                }
            }
            .sheet(isPresented: $showBulkDeleteAllTweets) {
                NavigationView {
                    if let account = account, account == user.account {
                        DeleteBulkTweetsAllTweetsView(account: account, isPresented: $showBulkDeleteAllTweets)
                    } else {
                        EmptyView()
                    }
                }
            }
        }
        
        @Sendable
        private func refresh() async {
            guard isRefreshing == false else {
                return
            }

            isRefreshing = true

            let task = Task.detached {
                if let account = await user.account {
                    try await Session.shared.updateAccount(account.objectID)
                } else if let account = await account {
                    try await Session.shared.updateUsers(ids: [user.id].compactMap { $0 }, with: .session(for: account))
                }
            }

            #if os(iOS)
            let backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask {
                task.cancel()
            }
            #endif

            do {
                _ = try await task.value

                isRefreshing = false
            } catch {
                Logger().error("Error occurred: \(String(reflecting: error), privacy: .public)")
                self.error = TweetNestError(error)
                showErrorAlert = true
                isRefreshing = false
            }

            #if os(iOS)
            UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
            #endif
        }
    }
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView(user: Account.preview.user!)
    }
}
