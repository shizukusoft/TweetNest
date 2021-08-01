//
//  AccountView.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/02/24.
//

import SwiftUI
import TweetNestKit

struct AccountView: View {
    let account: Account

    @FetchRequest
    private var userDatas: FetchedResults<UserData>

    var followingsCount: Int? {
        userDatas.last?.followingUserIDs?.count
    }

    var followersCount: Int? {
        userDatas.last?.followerUserIDs?.count
    }

    @State var showErrorAlert: Bool = false
    @State var error: Error? = nil

    var body: some View {
        List {
            Section {
                UserProfileView(userData: userDatas.last)
                    .padding(8)

                HStack {
                    Text("Following:")
                    Spacer()
                    if let count = followingsCount {
                        Text(String(count))
                    }
                }

                HStack {
                    Text("Followers:")
                    Spacer()
                    if let count = followersCount {
                        Text(String(count))
                    }
                }
            }

            Section {
                if let user = account.user {
                    NavigationLink {
                        UserAllDataView(user: user)
                    } label: {
                        Text("Show All Data")
                    }
                }
            }
        }
        .navigationTitle(Text(account.user?.sortedUserDatas?.last?.name ?? "#\(account.id)"))
        .toolbar(content: {
            ToolbarItem(placement: .automatic) {
                Button(action: refresh) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
            }
        })
        .alert("Error", isPresented: $showErrorAlert, presenting: error) { _ in

        } message: {
            $0.flatMap {
                Text($0.localizedDescription)
            }
        }
    }

    init(account: Account) {
        self.account = account
        self._userDatas = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Account.creationDate, ascending: true)],
            predicate: NSPredicate(format: "user.id == %@", account.user?.id ?? ""),
            animation: .default
        )
    }

    func refresh() {
        Task {
            do {
                try await account.updateUser()
            } catch {
                self.error = error
                showErrorAlert = true
            }
        }
    }
}
