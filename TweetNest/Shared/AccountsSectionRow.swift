//
//  AccountsSectionRow.swift
//  AccountsListRow
//
//  Created by Jaehong Kang on 2021/07/31.
//

import SwiftUI
import TweetNestKit

struct AccountsSectionRow: View {
    private static let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()

    let account: Account

    @Binding var navigationItemSelection: AppSidebarNavigation.NavigationItem?
    @State var isExpanded: Bool = true

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            NavigationLink(tag: .followings(account), selection: $navigationItemSelection) {
                UsersList(userIDs: account.user?.sortedUserDatas?.last?.followingUserIDs ?? [])
                    .navigationTitle(Text("Followings"))
            } label: {
                Text("Followings")
            }
            .deleteDisabled(true)

            NavigationLink(tag: .followers(account), selection: $navigationItemSelection) {
                UsersList(userIDs: account.user?.sortedUserDatas?.last?.followerUserIDs ?? [])
                    .navigationTitle(Text("Followers"))
            } label: {
                Text("Followers")
            }
            .deleteDisabled(true)
        } label: {
            NavigationLink(tag: .account(account), selection: $navigationItemSelection) {
                AccountView(account: account)
            } label: {
                Label {
                    Text(account.user?.sortedUserDatas?.last?.username ?? (account.user?.id).flatMap { "#\($0)" } ?? Self.itemFormatter.string(from: account.creationDate!))
                } icon: {
                    AsyncImage(url: account.user?.sortedUserDatas?.last?.profileImageURL) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 16, height: 16)
                    .cornerRadius(8)
                }
            }
        }
    }
}

struct AccountsSectionRow_Previews: PreviewProvider {
    static var previews: some View {
        AccountsSectionRow(account: .preview, navigationItemSelection: .constant(nil))
    }
}
