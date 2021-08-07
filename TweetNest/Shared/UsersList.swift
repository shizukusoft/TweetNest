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
    private let userIDs: OrderedSet<String>

    @FetchRequest private var users: FetchedResults<User>
    @State private var searchQuery: String = ""

    var body: some View {
        List {
            ForEach(
                users.sorted(by: { userIDs.firstIndex(of: $0.id) ?? -1 < userIDs.firstIndex(of: $1.id) ?? -1})
            ) { user in
                NavigationLink {
                    UserView(user: user)
                } label: {
                    HStack(spacing: 8) {
                        ProfileImage(userData: user.sortedUserDatas?.last)
                            .frame(width: 24, height: 24)

                        HStack(spacing: 4) {
                            Text(user.sortedUserDatas?.last?.name ?? "#\(user.id)")
                                .lineLimit(1)

                            if let username = user.sortedUserDatas?.last?.username {
                                Text("@\(username)")
                                    .lineLimit(1)
                                    .foregroundColor(Color.gray)
                                    .layoutPriority(1)
                            }
                        }
                    }
                }
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
                            NSPredicate(format: "ANY userDatas.name CONTAINS[cd] %@", newSearchQuery),
                            NSPredicate(format: "ANY userDatas.username CONTAINS[cd] %@", newSearchQuery)
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
