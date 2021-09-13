//
//  UserRows.swift
//  UserRows
//
//  Created by Jaehong Kang on 2021/09/04.
//

import SwiftUI
import CoreData
import TweetNestKit
import OrderedCollections

struct UserRows<Icon>: View where Icon: View {
    private let icon: Icon?
    private let userIDs: OrderedSet<String>

    @Environment(\.account) private var account: Account?

    @SectionedFetchRequest private var userDetailsByUser: SectionedFetchResults<String?, UserDetail>

    @Binding private var searchQuery: String

    var body: some View {
        ForEach(userIDs, id: \.self) { userID in
            let displayUserID = Int64(userID).flatMap { "#\($0.twnk_formatted())" } ?? "#\(userID)"
            let userDetailsSection = userDetailsByUser.first(where: { $0.id == userID })

            if let latestUserDetail = userDetailsSection?.first {
                if
                    searchQuery.isEmpty ||
                    userDetailsSection?.contains(where: {
                        ($0.name?.localizedCaseInsensitiveContains(searchQuery) == true || $0.username?.localizedCaseInsensitiveContains(searchQuery) == true)
                    }) == true
                {
                    Label {
                        Label {
                            if let user = latestUserDetail.user {
                                NavigationLink {
                                    UserView(user: user)
                                        .environment(\.account, account)
                                } label: {
                                    userLabelTitle(latestUserDetail: latestUserDetail, displayUserID: displayUserID)
                                }
                            } else {
                                userLabelTitle(latestUserDetail: latestUserDetail, displayUserID: displayUserID)
                            }
                        } icon: {
                            ProfileImage(profileImageURL: latestUserDetail.profileImageURL)
                                .frame(width: 24, height: 24)
                        }
                        #if os(watchOS)
                        .labelStyle(.titleOnly)
                        #endif
                    } icon: {
                        icon
                    }
                    .accessibilityLabel(Text(verbatim: latestUserDetail.name ?? displayUserID))
                }
            } else {
                if searchQuery.isEmpty || displayUserID.contains(searchQuery) {
                    Label {
                        Text(verbatim: displayUserID)
                    } icon: {
                        icon
                    }
                }
            }
        }
    }

    private init<C>(userIDs: C, searchQuery: Binding<String>, icon: Icon?) where C: Sequence, C.Element == String {
        self.userIDs = OrderedSet(userIDs)

        self._userDetailsByUser = SectionedFetchRequest(
            fetchRequest: {
                let fetchRequest = UserDetail.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "user.id in %@", Array(userIDs))
                fetchRequest.sortDescriptors = [
                    NSSortDescriptor(keyPath: \UserDetail.user?.id, ascending: true),
                    NSSortDescriptor(keyPath: \UserDetail.user?.creationDate, ascending: false),
                    NSSortDescriptor(keyPath: \UserDetail.creationDate, ascending: false),
                ]
                fetchRequest.relationshipKeyPathsForPrefetching = ["user", "user.id"]
                fetchRequest.propertiesToFetch = ["name", "username", "profileImageURL"]
                fetchRequest.fetchBatchSize = 1000

                return fetchRequest
            }(),
            sectionIdentifier: \.user?.id,
            animation: .default
        )

        self._searchQuery = searchQuery
        self.icon = icon
    }

    init<C>(userIDs: C, searchQuery: Binding<String>, @ViewBuilder icon: () -> Icon) where C: Sequence, C.Element == String {
        self.init(userIDs: userIDs, searchQuery: searchQuery, icon: icon())
    }

    init<C>(userIDs: C, searchQuery: Binding<String>) where Icon == EmptyView, C: Sequence, C.Element == String {
        self.init(userIDs: userIDs, searchQuery: searchQuery, icon: nil)
    }

    @ViewBuilder
    private func userLabelTitle(latestUserDetail: UserDetail, displayUserID: String) -> some View {
        TweetNestStack {
            Text(verbatim: latestUserDetail.name ?? displayUserID)
                .lineLimit(1)

            if let username = latestUserDetail.username {
                Text(verbatim: "@\(username)")
                    .lineLimit(1)
                    .layoutPriority(1)
                    .foregroundColor(Color.gray)
            }
        }
    }
}

struct UserRows_Previews: PreviewProvider {
    static var previews: some View {
        UserRows(userIDs: [], searchQuery: .constant(""))
    }
}
