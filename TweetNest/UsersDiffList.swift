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
    @StateObject private var userDetailsFetchedResultsController: FetchedResultsController<ManagedUserDetail>

    let title: LocalizedStringKey
    let diffKeyPath: KeyPath<ManagedUserDetail, [String]?>

    @State private var searchQuery: String = ""

    @ViewBuilder private var usersDiffList: some View {
        let userDetails = userDetailsFetchedResultsController.fetchedObjects
        let userDetailPairs = userDetails
            .lazy
            .indexed()
            .map { (index, element) -> (ManagedUserDetail, ManagedUserDetail?) in
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
        usersDiffList
            #if os(macOS)
            .frame(minWidth: 254)
            #endif
            .navigationTitle(title)
    }

    init(_ title: LocalizedStringKey, userID: String?, diffKeyPath: KeyPath<ManagedUserDetail, [String]?>) {
        self._userDetailsFetchedResultsController = StateObject(
            wrappedValue: FetchedResultsController<ManagedUserDetail>(
                fetchRequest: {
                    let fetchRequest = ManagedUserDetail.fetchRequest()
                    fetchRequest.predicate = NSCompoundPredicate(
                        andPredicateWithSubpredicates: Array(
                            [
                                userID.flatMap { NSPredicate(format: "userID == %@", $0) } ?? NSPredicate(value: false),
                                diffKeyPath._kvcKeyPathString.flatMap { NSPredicate(format: "%K != NULL", $0) },
                            ].compacted()
                        )
                    )
                    fetchRequest.sortDescriptors = [
                        NSSortDescriptor(keyPath: \ManagedUserDetail.creationDate, ascending: false),
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

// struct UsersDiffList_Previews: PreviewProvider {
//    static var previews: some View {
//        UsersDiffList()
//    }
// }
