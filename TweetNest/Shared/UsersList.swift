//
//  UsersList.swift
//  UsersList
//
//  Created by Jaehong Kang on 2021/08/01.
//

import SwiftUI
import TweetNestKit
import OrderedCollections

struct UsersList: View {
    let userIDs: OrderedSet<String>

    @SectionedFetchRequest private var userDetailsByUser: SectionedFetchResults<String?, UserDetail>
    @State private var searchQuery: String = ""

    var body: some View {
        List(userIDs, id: \.self) { userID in
            userLabel(userID: userID)
        }
        .searchable(text: $searchQuery)
    }

    init<C>(userIDs: C) where C: Sequence, C.Element == String {
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
                fetchRequest.propertiesToFetch = ["name", "username", "profileImageURL", "user"]

                return fetchRequest
            }(),
            sectionIdentifier: \.user?.id
        )
    }

    @ViewBuilder
    private func userLabel(userID: String) -> some View {
        let displayUserID = Int64(userID).flatMap { "#\($0.twnk_formatted())" } ?? "#\(userID)"
        let userDetailsSection = userDetailsByUser.first(where: { $0.id == userID })

        if let latestUserDetail = userDetailsSection?.first {
            if
                searchQuery.isEmpty ||
                userDetailsSection?.contains(where: {
                    ($0.name?.localizedCaseInsensitiveContains(searchQuery) == true || $0.username?.localizedCaseInsensitiveContains(searchQuery) == true)
                }) == true
            {
                UserLabel(userDetail: latestUserDetail, displayUserID: displayUserID)
                    #if os(watchOS)
                    .labelStyle(.titleOnly)
                    #endif
                    .accessibilityLabel(Text(verbatim: latestUserDetail.name ?? displayUserID))
            }
        } else {
            if searchQuery.isEmpty || displayUserID.contains(searchQuery) {
                UserLabel(displayUserID: displayUserID)
            }
        }
    }
}

struct UsersList_Previews: PreviewProvider {
    static var previews: some View {
        UsersList(userIDs: [])
    }
}
