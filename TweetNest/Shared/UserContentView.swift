//
//  UserContentView.swift
//  UserContentView
//
//  Created by Jaehong Kang on 2021/08/15.
//

import SwiftUI
import TweetNestKit
import UnifiedLogging

struct UserContentView: View {
    @Environment(\.account) var account: Account?
    @ObservedObject var user: User

    var lastUserData: UserData? {
        user.sortedUserDatas?.last
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

    var userProfileURL: URL {
        URL(string: "https://twitter.com/intent/user?user_id=\(user.id)")!
    }
    
    @State var showBulkDeleteRecentTweets: Bool = false
    @State var showBulkDeleteAllTweets: Bool = false
    
    @ViewBuilder
    var deleteMenu: some View {
        Menu {
            if account != nil {
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
            if let lastUserData = lastUserData {
                Section {
                    UserDataProfileView(userData: lastUserData)
                } header: {
                    Text("Latest Profile")
                } footer: {
                    VStack(alignment: .leading) {
                        Text(verbatim: "#\(Int64(user.id)?.formatted() ?? user.id)")
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
        .navigationTitle(Text(verbatim: lastUserData?.username.flatMap({"@\($0)"}) ?? "#\(user.id)"))
        #if os(iOS)
        .refreshable(action: refresh)
        #endif
        .toolbar {
            let userProfileURL = URL(string: "https://twitter.com/intent/user?user_id=\(user.id)")!
            ToolbarItemGroup(placement: .automatic) {
                if shouldCompactToolbar {
                    Menu {
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

                        #if os(iOS)
                        Divider()

                        Button(Label(Text("Share"), systemImage: "square.and.arrow.up")) {
                            shareSheetURL = userProfileURL
                        }
                        #endif
                        
                        Divider()
                        
                        deleteMenu
                    } label: {
                        Label(Text("More"), systemImage: "ellipsis.circle")
                            .labelStyle(.iconOnly)
                    }
                } else {
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
                    
                    #if !os(iOS)
                    Button(Label(Text("Refresh"), systemImage: "arrow.clockwise")) {
                        Task {
                            refresh
                        }
                    }
                    .disabled(isRefreshing)
                    #endif
                    
                    deleteMenu
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
                if let account = account {
                    DeleteBulkTweetsRecentTweetsView(account: account, isPresented: $showBulkDeleteRecentTweets)
                } else {
                    EmptyView()
                }
            }
        }
        .sheet(isPresented: $showBulkDeleteAllTweets) {
            NavigationView {
                if let account = account {
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
                try await Session.shared.updateUsers(ids: [user.id], with: .session(for: account))
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

struct UserContentView_Previews: PreviewProvider {
    static var previews: some View {
        UserContentView(user: Account.preview.user!)
    }
}
