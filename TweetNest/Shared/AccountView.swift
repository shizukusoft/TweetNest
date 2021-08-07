//
//  AccountView.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/02/24.
//

import SwiftUI
import TweetNestKit
import UnifiedLogging
#if os(iOS)
import UIKit
#endif

struct AccountView: View {
    @ObservedObject var account: Account

    @State var isRefreshing: Bool = false

    @State var showErrorAlert: Bool = false
    @State var error: Error? = nil

    var body: some View {
        Group {
            if let user = account.user {
                UserView(user: user)
            } else {
                List {
                    
                }
            }
        }
        #if os(iOS)
        .refreshable {
            await refresh()
        }
        #else
        .toolbar(content: {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    Task {
                        refresh
                    }
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .disabled(isRefreshing)
            }
        })
        #endif
        .alertError(isPresented: $showErrorAlert, error: $error)
    }

    private func refresh() async {
        guard isRefreshing == false else {
            return
        }

        isRefreshing = true

        let task = Task.detached {
            try await Session.shared.updateUser(forAccountObjectID: account.objectID)
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
            Logger().error("Error occured: \(String(reflecting: error), privacy: .public)")
            self.error = error
            showErrorAlert = true
            isRefreshing = false
        }

        #if os(iOS)
        UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
        #endif
    }
}

#if DEBUG
struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView(account: Account.preview)
    }
}
#endif
