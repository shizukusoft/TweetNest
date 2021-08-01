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

    var profileImageURL: URL {
        let profileImageURL = userDatas.last?.profileImageURL ?? URL(string: "https://abs.twimg.com/sticky/default_profile_images/default_profile_normal.png")!

        return profileImageURL
            .deletingLastPathComponent()
            .appendingPathComponent(profileImageURL.lastPathComponent.replacingOccurrences(of: "_normal.", with: "."))
    }

    var name: String {
        userDatas.last?.name ?? "#\(account.id)"
    }

    var username: String? {
        userDatas.last?.username.flatMap {
            "@\($0)"
        }
    }

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
                HStack(spacing: 8) {
                    AsyncImage(url: profileImageURL) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 50, height: 50)
                    .cornerRadius(25)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(name)
                        if let username = username {
                            Text(username)
                        }
                    }
                }

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
