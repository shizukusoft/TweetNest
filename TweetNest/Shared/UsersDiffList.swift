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
    @StateObject private var userDetailsFetchedResultsController: FetchedResultsController<UserDetail>

    let title: LocalizedStringKey
    let diffKeyPath: KeyPath<UserDetail, [String]?>

    @State private var searchQuery: String = ""

    @ViewBuilder private var usersDiffList: some View {
        let userDetails = userDetailsFetchedResultsController.fetchedObjects

        List(userDetails) { userDetail in
            let userDetailIndex = userDetails.firstIndex(of: userDetail)
            let previousUserDetailIndex = userDetailIndex.flatMap { userDetails.index(after: $0) }
            let previousUserDetail = previousUserDetailIndex.flatMap { userDetails.indices.contains($0) ? userDetails[$0] : nil }

            UsersDiffListSection(
                diffKeyPath: diffKeyPath,
                searchQuery: searchQuery,
                previousUserDetail: previousUserDetail,
                userDetail: userDetail
            )
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

    init(_ title: LocalizedStringKey, user: User?, diffKeyPath: KeyPath<UserDetail, [String]?>) {
        self._userDetailsFetchedResultsController = StateObject(
            wrappedValue: FetchedResultsController<UserDetail>(
                fetchRequest: {
                    let fetchRequest = UserDetail.fetchRequest()
                    fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                        user.flatMap { NSPredicate(format: "user == %@", $0.objectID) } ?? NSPredicate(value: false),
                        diffKeyPath._kvcKeyPathString.flatMap { NSPredicate(format: "%K != NULL", $0) },
                    ].compactMap({ $0 }))
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
                managedObjectContext: TweetNestApp.session.persistentContainer.viewContext,
                cacheName: ["UserDetails", user?.id, diffKeyPath._kvcKeyPathString].compactMap { $0 }.joined(separator: "-")
            )
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
