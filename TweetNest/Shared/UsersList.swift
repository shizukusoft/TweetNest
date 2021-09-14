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

    @FetchRequest private var userDetails: FetchedResults<UserDetail>
    @State private var userDetailsByUser: OrderedDictionary<String?, [UserDetail]>

    @State private var searchQuery: String = ""

    var body: some View {
        List(userIDs, id: \.self) { userID in
            userLabel(userID: userID)
        }
        .searchable(text: $searchQuery)
        .onChange(of: Array(userDetails)) { newValue in
            userDetailsByUser = OrderedDictionary(grouping: newValue, by: { $0.user?.id })
        }
    }

    init<C>(userIDs: C) where C: Sequence, C.Element == String {
        self.userIDs = OrderedSet(userIDs)

        let userDetailsFetchRequest = UserDetail.fetchRequest()
        userDetailsFetchRequest.predicate = NSPredicate(format: "user.id in %@", Array(userIDs))
        userDetailsFetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \UserDetail.user?.id, ascending: true),
            NSSortDescriptor(keyPath: \UserDetail.user?.creationDate, ascending: false),
            NSSortDescriptor(keyPath: \UserDetail.creationDate, ascending: false),
        ]
        userDetailsFetchRequest.relationshipKeyPathsForPrefetching = ["user"]

        self._userDetails = FetchRequest(
            fetchRequest: userDetailsFetchRequest
        )

        let userDetails = (try? Session.shared.persistentContainer.viewContext.fetch(userDetailsFetchRequest)) ?? []
        self._userDetailsByUser = State(initialValue: OrderedDictionary(grouping: userDetails, by: { $0.user?.id }))
    }

    @ViewBuilder
    private func userLabel(userID: String) -> some View {
        let displayUserID = Int64(userID).flatMap { "#\($0.twnk_formatted())" } ?? "#\(userID)"
        let userDetails = userDetailsByUser[userID] ?? []

        if let latestUserDetail = userDetails.first {
            if
                searchQuery.isEmpty ||
                userDetails.contains(where: {
                    ($0.name?.localizedCaseInsensitiveContains(searchQuery) == true || $0.username?.localizedCaseInsensitiveContains(searchQuery) == true)
                })
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
