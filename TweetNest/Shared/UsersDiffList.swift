//
//  UsersDiffList.swift
//  UsersDiffList
//
//  Created by Jaehong Kang on 2021/08/09.
//

import SwiftUI
import TweetNestKit
import OrderedCollections

struct UsersDiffList: View {
    @FetchRequest private var userDetails: FetchedResults<UserDetail>

    let title: Text
    let diffKeyPath: KeyPath<UserDetail, [String]?>

    @State private var searchQuery: String = ""

    @ViewBuilder private var usersDiffList: some View {
        List(userDetails.indices, id: \.self) { userDetailIndex in
            let userDetail = userDetails[userDetailIndex]
            let previousUserDetailIndex = userDetailIndex + 1
            let previousUserDetail = userDetails.indices.contains(previousUserDetailIndex) ? userDetails[previousUserDetailIndex] : nil

            UsersDiffListSection(previousUserDetail: previousUserDetail, currentUserDetail: userDetail, diffKeyPath: diffKeyPath, searchQuery: $searchQuery)
        }
        .searchable(text: $searchQuery)
    }

    var body: some View {
        #if os(macOS)
        NavigationView {
            usersDiffList
                .listStyle(.plain)
                .navigationTitle(title)
        }
        .navigationViewStyle(.columns)
        #else
        usersDiffList
            .navigationTitle(title)
        #endif
    }

    init(user: User, diffKeyPath: KeyPath<UserDetail, [String]?>, title: Text) {
        self._userDetails = FetchRequest(
            fetchRequest: {
                let fetchRequest = UserDetail.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "user == %@", user.objectID)
                fetchRequest.sortDescriptors = [
                    NSSortDescriptor(keyPath: \UserDetail.creationDate, ascending: false),
                ]
                if let keyPathString = diffKeyPath._kvcKeyPathString {
                    fetchRequest.propertiesToFetch = ["creationDate", keyPathString]
                } else {
                    fetchRequest.returnsObjectsAsFaults = false
                }

                return fetchRequest
            }(),
            animation: .default
        )

        self.title = title
        self.diffKeyPath = diffKeyPath
    }
}

//struct UsersDiffList_Previews: PreviewProvider {
//    static var previews: some View {
//        UsersDiffList()
//    }
//}
