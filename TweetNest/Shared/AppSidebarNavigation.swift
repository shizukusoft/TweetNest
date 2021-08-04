//
//  AppSidebarNavigation.swift
//  AppSidebarNavigation
//
//  Created by Jaehong Kang on 2021/07/31.
//

import SwiftUI
import TweetNestKit

struct AppSidebarNavigation: View {
    enum NavigationItem: Hashable {
        case profile(Account)
        case followings(Account)
        case followers(Account)
    }

    @State private var navigationItemSelection: NavigationItem? = nil

    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [
            SortDescriptor.init(\.sortOrder, order: .forward),
            SortDescriptor.init(\.creationDate, order: .forward),
        ],
        animation: .default)
    private var accounts: FetchedResults<Account>

    var body: some View {
        NavigationView {
            List {
                ForEach(accounts) { account in
                    Section {
                        NavigationLink(tag: .profile(account), selection: $navigationItemSelection) {
                            AccountView(account: account)
                        } label: {
                            Label("Account", systemImage: "person")
                        }

                        NavigationLink(tag: .followings(account), selection: $navigationItemSelection) {
                            UsersList(userIDs: account.user?.sortedUserDatas?.last?.followingUserIDs ?? [])
                                .navigationTitle(Text("Followings"))
                        } label: {
                            Label("Followings", systemImage: "person.2")
                        }
                        .deleteDisabled(true)

                        NavigationLink(tag: .followers(account), selection: $navigationItemSelection) {
                            UsersList(userIDs: account.user?.sortedUserDatas?.last?.followerUserIDs ?? [])
                                .navigationTitle(Text("Followers"))
                        } label: {
                            Label("Followers", systemImage: "person.2")
                        }
                        .deleteDisabled(true)
                    } header: {
                        Label {
                            Text((account.user?.sortedUserDatas?.last?.username).flatMap { "@\($0)" } ?? "#\(account.id)")
                        } icon: {
                            Group {
                                if let profileImage = Image(data: account.user?.sortedUserDatas?.last?.profileImageData) {
                                    profileImage
                                        .resizable()
                                } else {
                                    Color.gray
                                }
                            }
                            .frame(width: 24, height: 24)
                            .cornerRadius(12)
                        }
                    }

                }
            }
            .listStyle(.sidebar)
            .navigationTitle(Text("TweetNest"))
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    AppSidebarMenu()
                }
            }
        }
    }
}

#if DEBUG
struct AppSidebarNavigation_Previews: PreviewProvider {
    static var previews: some View {
        AppSidebarNavigation()
            .environment(\.managedObjectContext, Session.preview.container.viewContext)
    }
}
#endif
