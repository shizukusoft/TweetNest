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
    @FetchRequest
    private var users: FetchedResults<User>

    var body: some View {
        List {
            ForEach(
                users.sorted(by: { userIDs.firstIndex(of: $0.id) ?? -1 < userIDs.firstIndex(of: $1.id) ?? -1})
            ) { user in
                NavigationLink {
                    UserAllDataView(user: user)
                } label: {
                    HStack(spacing: 8) {
                        AsyncImage(url: user.sortedUserDatas?.last?.profileImageURL) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 24, height: 24)
                        .cornerRadius(16)
                        HStack(spacing: 4) {
                            Text(user.sortedUserDatas?.last?.name ?? "#\(user.id)")

                            if let username = user.sortedUserDatas?.last?.username {
                                Text("@\(username)")
                                    .foregroundColor(Color.gray)
                            }
                        }
                    }
                }
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
