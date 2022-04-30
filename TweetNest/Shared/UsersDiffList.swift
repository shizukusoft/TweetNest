//
//  UsersDiffList.swift
//  UsersDiffList
//
//  Created by Jaehong Kang on 2021/08/09.
//

import SwiftUI
import CoreData
import TweetNestKit
import OrderedCollections
import Algorithms

struct UsersDiffList: View {
    @StateObject private var userDetailsFetchedResultsController: FetchedResultsController<UserDetail>

    let title: LocalizedStringKey
    let diffKeyPath: KeyPath<UserDetail, [String]?>

    @State private var searchQuery: String = ""

    @ViewBuilder private var usersDiffList: some View {
        let userDetails = userDetailsFetchedResultsController.fetchedObjects
        let userDetailPairs = userDetails
            .lazy
            .indexed()
            .map { (index: LazySequence<[UserDetail]>.Index, element: LazySequence<[UserDetail]>.Element) -> (UserDetail, UserDetail?) in
                let nextIndex = userDetails.index(after: index)

                return (element, userDetails.indices.contains(nextIndex) ? userDetails[nextIndex] : nil)
            }

        List(userDetailPairs, id: \.0) {
            UsersDiffListSection(
                diffKeyPath: diffKeyPath,
                searchQuery: searchQuery,
                previousUserDetail: $0.1,
                userDetail: $0.0
            )
        }
        .searchable(text: $searchQuery)
    }

    var body: some View {
        #if os(macOS)
        NavigationView {
            usersDiffList
                .frame(minWidth: 254)
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
                    fetchRequest.predicate = NSCompoundPredicate(
                        andPredicateWithSubpredicates: Array(
                            [
                                user.flatMap { NSPredicate(format: "user == %@", $0.objectID) } ?? NSPredicate(value: false),
                                diffKeyPath._kvcKeyPathString.flatMap { NSPredicate(format: "%K != NULL", $0) },
                            ].compacted()
                        )
                    )
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
                managedObjectContext: TweetNestApp.session.persistentContainer.viewContext
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
