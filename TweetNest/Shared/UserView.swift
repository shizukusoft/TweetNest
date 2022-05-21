//
//  UserView.swift
//  UserView
//
//  Created by Jaehong Kang on 2021/08/02.
//

import SwiftUI
import CoreData
import TweetNestKit
import BackgroundTask
import UnifiedLogging

struct UserView: View {
    let userID: String

    @Environment(\.account) var account: ManagedAccount?

    @StateObject private var usersFetchedResultsController: FetchedResultsController<ManagedUser>
    @StateObject private var userDetailsFetchedResultsController: FetchedResultsController<ManagedUserDetail>

    @State var isRefreshing: Bool = false

    @State var showErrorAlert: Bool = false
    @State var error: TweetNestError?

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
    @State var safariSheetURL: URL?
    @State var shareSheetURL: URL?
    #endif

    var userProfileURL: URL {
        URL(string: "https://twitter.com/intent/user?user_id=\(userID)")!
    }

    @State var showBulkDeleteRecentTweets: Bool = false
    #if os(iOS) || os(macOS)
    @State var showBulkDeleteAllTweets: Bool = false
    #endif

    @ViewBuilder
    var deleteMenu: some View {
        #if os(iOS) || os(macOS)
        Menu {
            Button(role: .destructive) {
                showBulkDeleteRecentTweets = true
            } label: {
                Text("Delete Recent Tweets")
            }
            .accessibilityIdentifier("Delete Recent Tweets")

            Button(role: .destructive) {
                showBulkDeleteAllTweets = true
            } label: {
                Text("Delete All Tweets")
            }
            .accessibilityIdentifier("Delete All Tweets")
        } label: {
            Label {
                Text("Delete")
            } icon: {
                Image(systemName: "trash")
            }
        }
        .accessibilityIdentifier("Delete")
        #else
        Button(role: .destructive) {
            showBulkDeleteRecentTweets = true
        } label: {
            Text("Delete Recent Tweets")
        }
        .accessibilityIdentifier("Delete Recent Tweets")
        #endif
    }

    @ViewBuilder private var refreshButton: some View {
        Button {
            Task {
                refresh
            }
        } label: {
            Label("Refresh", systemImage: "arrow.clockwise")
        }
        .disabled(isRefreshing)
    }

    var body: some View {
        let user = usersFetchedResultsController.fetchedObjects.first
        let userDetails = userDetailsFetchedResultsController.fetchedObjects
        let latestUserDetail: ManagedUserDetail? = userDetails.first

        Group {
            #if os(macOS)
            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 8) {
                    if let latestUserDetail = latestUserDetail {
                        UserDetailProfileView(userDetail: latestUserDetail)
                    }
                    FootnotesView(userID: userID, user: user)
                }
                .padding()

                AllDataView(userDetails: userDetails)
            }
            #else
            List {
                Section {
                    if let latestUserDetail = latestUserDetail {
                        UserDetailProfileView(userDetail: latestUserDetail)
                    }
                } header: {
                    Text("Latest Profile")
                } footer: {
                    FootnotesView(userID: userID, user: user)
                }

                #if os(watchOS)
                if let account = account, user?.accounts?.contains(account) == true {
                    Section {
                        deleteMenu
                    }
                }
                #endif

                Section(String(localized: "All Data")) {
                    AllDataView(userDetails: userDetails)
                }
            }
            #endif
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .navigationTitle(Text(verbatim: latestUserDetail?.displayUsername ?? userID.displayUserID))
        .refreshable(action: refresh)
        #if os(iOS) || os(macOS)
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                if shouldCompactToolbar {
                    Menu {
                        Link(destination: userProfileURL) {
                            Label("Open Profile", systemImage: "safari")
                        }

                        #if os(iOS)
                        Button {
                            safariSheetURL = userProfileURL
                        } label: {
                            Label("Open Profile in Safari", systemImage: "safari")
                        }
                        #endif

                        #if os(iOS)
                        Divider()

                        Button {
                            shareSheetURL = userProfileURL
                        } label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        #endif

                        if let account = account, user?.accounts?.contains(account) == true {
                            Divider()

                            deleteMenu
                        }
                    } label: {
                        Label("More", systemImage: "ellipsis.circle")
                            .labelStyle(.iconOnly)
                    }
                    .accessibilityIdentifier("More")
                    .accessibilityLabel("More")
                } else {
                    if let account = account, user?.accounts?.contains(account) == true {
                        deleteMenu
                    }

                    #if os(iOS)
                    Button {
                        shareSheetURL = userProfileURL
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    #endif

                    Link(destination: userProfileURL) {
                        Label("Open Profile", systemImage: "safari")
                    }
                    #if os(iOS)
                    .contextMenu {
                        Link(destination: userProfileURL) {
                            Label("Open Profile", systemImage: "safari")
                        }

                        Button {
                            safariSheetURL = userProfileURL
                        } label: {
                            Label("Open Profile in Safari", systemImage: "safari")
                        }
                    }
                    #endif

                    #if os(macOS)
                    refreshButton
                    #endif
                }
            }
        }
        #else
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                refreshButton
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
        .sheet(isPresented: $showBulkDeleteRecentTweets) {
            if let account = account, user?.accounts?.contains(account) == true {
                #if os(macOS)
                BatchDeleteTweetsView(isPresented: $showBulkDeleteRecentTweets, account: account, source: .recentTweets)
                    .padding()
                    .frame(minWidth: 320, minHeight: 240)
                #else
                NavigationView {
                    BatchDeleteTweetsView(isPresented: $showBulkDeleteRecentTweets, account: account, source: .recentTweets)
                }
                #endif
            }
        }
        #if os(iOS) || os(macOS)
        .sheet(isPresented: $showBulkDeleteAllTweets) {
            if let account = account, user?.accounts?.contains(account) == true {
                #if os(macOS)
                BatchDeleteTweetsView(isPresented: $showBulkDeleteAllTweets, account: account, source: .twitterArchive)
                    .padding()
                    .frame(minWidth: 320, minHeight: 240)
                #else
                NavigationView {
                    BatchDeleteTweetsView(isPresented: $showBulkDeleteAllTweets, account: account, source: .twitterArchive)
                }
                #endif
            }
        }
        #endif
    }

    init(userID: String) {
        self.userID = userID

        self._usersFetchedResultsController = StateObject(
            wrappedValue: FetchedResultsController(
                fetchRequest: {
                    let fetchRequest = ManagedUser.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "id == %@", userID)
                    fetchRequest.sortDescriptors = [
                        NSSortDescriptor(keyPath: \ManagedUser.creationDate, ascending: false),
                    ]
                    fetchRequest.fetchLimit = 1
                    fetchRequest.propertiesToFetch = ["id", "lastUpdateStartDate", "lastUpdateEndDate"]
                    fetchRequest.returnsObjectsAsFaults = false

                    return fetchRequest

                }(),
                managedObjectContext: TweetNestApp.session.persistentContainer.viewContext
            )
        )

        self._userDetailsFetchedResultsController = StateObject(
            wrappedValue: FetchedResultsController(
                fetchRequest: {
                    let fetchRequest = ManagedUserDetail.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "userID == %@", userID)
                    fetchRequest.sortDescriptors = [
                        NSSortDescriptor(keyPath: \ManagedUserDetail.creationDate, ascending: false),
                    ]
                    fetchRequest.returnsObjectsAsFaults = false

                    return fetchRequest

                }(),
                managedObjectContext: TweetNestApp.session.persistentContainer.viewContext
            )
        )
    }
}

extension UserView {
    @MainActor
    private var accountObjectID: NSManagedObjectID? {
        account?.objectID
    }

    @MainActor
    private var isUserContainsAccount: Bool {
        guard let account = account else { return false }

        return usersFetchedResultsController.fetchedObjects.first?.accounts?.contains(account) == true
    }

    private func startRefreshing() {
        isRefreshing = true
    }

    private func endRefreshing() {
        isRefreshing = false
    }

    private func presentError(error: TweetNestError) {
        self.error = error
        showErrorAlert = true
    }

    @Sendable
    private func refresh() async {
        guard isRefreshing == false else {
            return
        }

        isRefreshing = true
        defer {
            isRefreshing = false
        }

        guard let accountObjectID = accountObjectID else {
            return
        }

        do {
            try await withExtendedBackgroundExecution {
                if isUserContainsAccount {
                    try await TweetNestApp.session.updateAccount(accountObjectID)
                } else {
                    _ = try await TweetNestApp.session.updateUsers(ids: [userID].compactMap { $0 }, accountObjectID: accountObjectID)[userID]
                }
            }
        } catch {
            Logger().error("Error occurred: \(String(reflecting: error), privacy: .public)")
            presentError(error: TweetNestError(error))
        }
    }
}

#if DEBUG
struct UserView_Previews: PreviewProvider {

    static var previews: some View {
        NavigationView {
            UserView(userID: ManagedAccount.preview.userID!)
            .environment(\.account, .preview)
        }
    }
}
#endif
