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
            UserRow(userID: userID, user: users.first(where: { $0.id == userID }), searchQuery: $searchQuery) {
                icon
            }
        }
    }

    init<C>(userIDs: C, searchQuery: Binding<String>, @ViewBuilder icon: () -> Icon) where C: Sequence, C.Element == String {
        self.userIDs = OrderedSet(userIDs)

        let usersFetchRequest = User.fetchRequest()
        usersFetchRequest.predicate = NSPredicate(format: "id IN %@", Array(userIDs))
        usersFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \User.id, ascending: true)]
        usersFetchRequest.propertiesToFetch = ["id"]

        self._users = FetchRequest(
            fetchRequest: usersFetchRequest,
            animation: .default
        )

        self._searchQuery = searchQuery
        self.icon = icon()
    }

    init<C>(userIDs: C, searchQuery: Binding<String>) where Icon == EmptyView, C: Sequence, C.Element == String {
        self.userIDs = OrderedSet(userIDs)

        let usersFetchRequest = User.fetchRequest()
        usersFetchRequest.predicate = NSPredicate(format: "id IN %@", Array(userIDs))
        usersFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \User.id, ascending: true)]
        usersFetchRequest.propertiesToFetch = ["id"]

        self._users = FetchRequest(
            fetchRequest: usersFetchRequest,
            animation: .default
        )

        self._searchQuery = searchQuery
        self.icon = nil
    }
}

struct UserRows_Previews: PreviewProvider {
    static var previews: some View {
        UserRows(userIDs: [], searchQuery: .constant(""))
    }
}
