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
    @Environment(\.account) var account: Account?
    private let userIDs: OrderedSet<String>

    @FetchRequest private var users: FetchedResults<User>
    @State private var searchQuery: String = ""

    var body: some View {
        List {
            ForEach(
                users.sorted(by: { $0.id.flatMap { userIDs.firstIndex(of: $0) } ?? -1 < $1.id.flatMap { userIDs.firstIndex(of: $0) } ?? -1})
            ) { user in
                UserRow(user: user)
            }
        }
        .searchable(text: $searchQuery)
        .onChange(of: searchQuery) { newSearchQuery in
            if newSearchQuery.isEmpty {
                users.nsPredicate = NSPredicate(format: "id IN %@", Array(userIDs))
            } else {
                users.nsPredicate = NSCompoundPredicate(
                    andPredicateWithSubpredicates: [
                        NSPredicate(format: "id IN %@", Array(userIDs)),
                        NSCompoundPredicate(orPredicateWithSubpredicates: [
                            NSPredicate(format: "ANY userDetails.name CONTAINS[cd] %@", newSearchQuery),
                            NSPredicate(format: "ANY userDetails.username CONTAINS[cd] %@", newSearchQuery)
                        ])
                    ]
                )
            }
        }
    }

    init(userIDs: [String]) {
        let userIDs = OrderedSet<String>(userIDs)

        self.userIDs = userIDs
        self._users = FetchRequest(
            sortDescriptors: [],
            predicate: NSPredicate(format: "id IN %@", Array(userIDs)),
            animation: .default
        )
    }
}

#if DEBUG
struct UsersList_Previews: PreviewProvider {
    static var previews: some View {
        UsersList(userIDs: [])
    }
}
#endif
