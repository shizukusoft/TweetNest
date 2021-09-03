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
    let userIDs: [String]

    @State private var searchQuery: String = ""

    var body: some View {
        List {
            ForEach(userIDs, id: \.self) { userID in
                UserRow(userID: userID, searchQuery: $searchQuery)
            }
        }
        .searchable(text: $searchQuery)
    }
}

struct UsersList_Previews: PreviewProvider {
    static var previews: some View {
        UsersList(userIDs: [])
    }
}
