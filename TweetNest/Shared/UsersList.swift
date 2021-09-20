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

    @State private var searchQuery: String = ""

    var body: some View {
        let userDetailsByUser = Dictionary<String?, [UserDetail]>(grouping: userDetails, by: { $0.user?.id })

        List(userIDs, id: \.self) { userID in
            userLabel(userID: userID, userDetails: userDetailsByUser[userID] ?? [])
        }
        .searchable(text: $searchQuery)
    }

    init<C>(userIDs: C) where C: Sequence, C.Element == String {
        self.userIDs = OrderedSet(userIDs)

        let userDetailsFetchRequest = UserDetail.fetchRequest()
        userDetailsFetchRequest.predicate = NSPredicate(format: "user.id in %@", Array(userIDs))
        userDetailsFetchRequest.sortDescriptors = []
        userDetailsFetchRequest.propertiesToFetch = ["name", "username"]

        self._userDetails = FetchRequest(
            fetchRequest: userDetailsFetchRequest
        )
    }

    @ViewBuilder
    private func userLabel(userID: String, userDetails: [UserDetail]) -> some View {
        let displayUserID = Int64(userID).flatMap { "#\($0.twnk_formatted())" } ?? "#\(userID)"

        if
            searchQuery.isEmpty ||
            displayUserID.contains(searchQuery) ||
            userDetails.contains(where: {
                ($0.name?.localizedCaseInsensitiveContains(searchQuery) == true || $0.displayUsername?.localizedCaseInsensitiveContains(searchQuery) == true)
            })
        {
            UserLabel(userID: userID)
                #if os(watchOS)
                .labelStyle(.titleOnly)
                #endif
        }
    }
}

struct UsersList_Previews: PreviewProvider {
    static var previews: some View {
        UsersList(userIDs: [])
    }
}
