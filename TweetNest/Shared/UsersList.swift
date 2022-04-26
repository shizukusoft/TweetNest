//
//  UsersList.swift
//  UsersList
//
//  Created by Jaehong Kang on 2021/08/01.
//

import SwiftUI
import CoreData
import TweetNestKit
import OrderedCollections

struct UsersList: View {
    let userIDs: OrderedSet<String>
    
    @State private var searchQuery: String = ""

    var body: some View {
        List {
            UserRows(
                userIDs: userIDs,
                searchQuery: searchQuery
            )
        }
        .searchable(text: $searchQuery)
    }

    init<C>(userIDs: C) where C: Sequence, C.Element == String {
        self.userIDs = OrderedSet(userIDs)
    }
}

struct UsersList_Previews: PreviewProvider {
    static var previews: some View {
        UsersList(userIDs: [])
    }
}
