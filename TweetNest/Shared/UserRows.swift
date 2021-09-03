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

    @FetchRequest private var users: FetchedResults<User>

    @Binding private var searchQuery: String

    var body: some View {
        ForEach(userIDs, id: \.self) { userID in
            let displayUserID = "#\(Int64(userID)?.twnk_formatted() ?? userID)"
            let user = users.first(where: { $0.id == userID })

            if let user = user {
                if
                    searchQuery.isEmpty ||
                    user.userDetails?.compactMap({ $0 as? UserDetail })
                        .contains(where: {
                            $0.name?.localizedCaseInsensitiveContains(searchQuery) == true || $0.username?.localizedCaseInsensitiveContains(searchQuery) == true
                        }) == true
                {
                    Label {
                        UserRow(user: user)
                    } icon: {
                        icon
                    }
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

    init(userIDs: OrderedSet<String>, searchQuery: Binding<String>, @ViewBuilder icon: () -> Icon) {
        self.userIDs = userIDs

        let usersFetchRequest = User.fetchRequest()
        usersFetchRequest.predicate = NSPredicate(format: "id IN %@", Array(userIDs))
        usersFetchRequest.propertiesToFetch = ["id"]
        usersFetchRequest.relationshipKeyPathsForPrefetching = ["userDetails"]
        usersFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \User.id, ascending: true)]

        self._users = FetchRequest(
            fetchRequest: usersFetchRequest,
            animation: .default
        )

        self._searchQuery = searchQuery
        self.icon = icon()
    }

    init(userIDs: OrderedSet<String>, searchQuery: Binding<String>) where Icon == EmptyView {
        self.userIDs = userIDs

        let usersFetchRequest = User.fetchRequest()
        usersFetchRequest.predicate = NSPredicate(format: "id IN %@", Array(userIDs))
        usersFetchRequest.propertiesToFetch = ["id"]
        usersFetchRequest.relationshipKeyPathsForPrefetching = ["userDetails"]
        usersFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \User.id, ascending: true)]

        self._users = FetchRequest(
            fetchRequest: usersFetchRequest,
            animation: .default
        )

        self._searchQuery = searchQuery
        self.icon = nil
    }

    init(userIDs: [String], searchQuery: Binding<String>, @ViewBuilder icon: () -> Icon) {
        self.init(userIDs: OrderedSet(userIDs), searchQuery: searchQuery, icon: icon)
    }

    init(userIDs: [String], searchQuery: Binding<String>) where Icon == EmptyView {
        self.init(userIDs: OrderedSet(userIDs), searchQuery: searchQuery)
    }
}

struct UserRows_Previews: PreviewProvider {
    static var previews: some View {
        UserRows(userIDs: [], searchQuery: .constant(""))
    }
}
