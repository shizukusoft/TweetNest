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
        
        #if os(iOS) || os(macOS)
        @State var showBulkDeleteRecentTweets: Bool = false
        @State var showBulkDeleteAllTweets: Bool = false
        #endif
        
        #if os(iOS) || os(macOS)
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
        #endif
        
        @ViewBuilder private var userView: some View {
            #if os(macOS)
            VStack(alignment: .leading, spacing: 8) {
                if let lastUserDetail = lastUserDetail {
                    VStack(alignment: .leading, spacing: 8) {
                        UserDetailProfileView(userDetail: lastUserDetail)
                        VStack(alignment: .leading) {
                            user.id.flatMap { Text(verbatim: "#\(Int64($0)?.twnk_formatted() ?? $0)") }
                            if let lastUpdateStartDate = user.lastUpdateStartDate, let lastUpdateEndDate = user.lastUpdateEndDate {
                                Group {
                                    if lastUpdateStartDate > lastUpdateEndDate && lastUpdateStartDate.addingTimeInterval(60) >= Date() {
                                        Text("Updating...")
                                    } else {
                                        Text("Updated \(lastUpdateEndDate, style: .relative) ago")
                                    }
                                }
                                .accessibilityAddTraits(.updatesFrequently)
                            }
                        }
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    }
                    .padding()
                }
                UserAllDataView(user: user)
            }
            #else
            List {
                if let lastUserDetail = lastUserDetail {
                    Section {
                        UserDetailProfileView(userDetail: lastUserDetail)
                    } header: {
                        Text("Latest Profile")
                    } footer: {
                        VStack(alignment: .leading) {
                            user.id.flatMap { Text(verbatim: "#\(Int64($0)?.twnk_formatted() ?? $0)") }
                            if let lastUpdateStartDate = user.lastUpdateStartDate, let lastUpdateEndDate = user.lastUpdateEndDate {
                                Group {
                                    if lastUpdateStartDate > lastUpdateEndDate && lastUpdateStartDate.addingTimeInterval(60) >= Date() {
                                        Text("Updating...")
                                    } else {
                                        Text("Updated \(lastUpdateEndDate, style: .relative) ago")
                                    }
                                }
                                .accessibilityAddTraits(.updatesFrequently)
                            }
                        }
                    }
                }
                UserAllDataView(user: user)
            }
            #endif
        }

        var body: some View {
            userView
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .navigationTitle(Text(verbatim: user.displayUsername ?? user.objectID.description))
                .refreshable(action: refresh)
                #if os(iOS) || os(macOS)
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
                #endif
                #if os(iOS)
                .sheet(item: $safariSheetURL) {
                    SafariView(url: $0)
                }
                .sheet(item: $shareSheetURL) {
                    ShareView(item: $0)
                }
                #endif
                .alert(isPresented: $showErrorAlert, error: error)
                #if os(iOS) || os(macOS)
                .sheet(isPresented: $showBulkDeleteRecentTweets) {
                    if let account = account, account == user.account {
                        #if os(macOS)
                        DeleteBulkTweetsRecentTweetsView(account: account, isPresented: $showBulkDeleteRecentTweets)
                            .padding()
                            .frame(minWidth: 200, minHeight: 180)
                        #else
                        NavigationView {
                            DeleteBulkTweetsRecentTweetsView(account: account, isPresented: $showBulkDeleteRecentTweets)
                        }
                        #endif
                    }
                }
                .sheet(isPresented: $showBulkDeleteAllTweets) {
                    if let account = account, account == user.account {
                        #if os(macOS)
                        DeleteBulkTweetsAllTweetsView(account: account, isPresented: $showBulkDeleteAllTweets)
                            .padding()
                            .frame(minWidth: 200, minHeight: 180)
                        #else
                        NavigationView {
                            DeleteBulkTweetsRecentTweetsView(account: account, isPresented: $showBulkDeleteRecentTweets)
                        }
                        #endif
                    }
                }
                #endif
        }
        
        @Sendable
        private func refresh() async {
            await withExtendedBackgroundExecution {
                guard isRefreshing == false else {
                    return
                }

                isRefreshing = true
                defer {
                    // FIXME: https://github.com/apple/swift/pull/38481/files
                    DispatchQueue.main.async {
                        isRefreshing = false
                    }
                }

                do {
                    if let account = user.account {
                        try await Session.shared.updateAccount(account.objectID)
                    } else if let account = account {
                        try await Session.shared.updateUsers(ids: [user.id].compactMap { $0 }, accountObjectID: account.objectID)
                    }
                } catch {
                    Logger().error("Error occurred: \(String(reflecting: error), privacy: .public)")
                    self.error = TweetNestError(error)
                    showErrorAlert = true
                }
            }
        }
    }
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView(user: Account.preview.user!)
    }
}
