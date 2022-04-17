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
    @State private var filteredUserIDsByNames: OrderedSet<String>?

    var body: some View {
        List {
            UserRows(
                userIDs: searchQuery.isEmpty ? userIDs : OrderedSet(userIDs.filter { $0.localizedCaseInsensitiveContains(searchQuery) || $0.displayUserID.localizedCaseInsensitiveContains(searchQuery) || (filteredUserIDsByNames?.contains($0) ?? true) })
            )
        }
        .searchable(text: $searchQuery)
        .onChange(of: searchQuery) { newValue in
            let searchQuery = newValue

            guard searchQuery.isEmpty == false else {
                self.filteredUserIDsByNames = nil
                return
            }

            Task.detached(priority: .userInitiated) {
                let fetchRequest = NSFetchRequest<NSDictionary>()
                fetchRequest.entity = User.entity()
                fetchRequest.resultType = .dictionaryResultType
                fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
                    NSPredicate(format: "userDetails.username CONTAINS[cd] %@", searchQuery),
                    NSPredicate(format: "userDetails.name CONTAINS[cd] %@", searchQuery),
                ])
                fetchRequest.propertiesToFetch = ["id"]
                fetchRequest.returnsObjectsAsFaults = false

                let filteredUserIDsByNames: OrderedSet<String> = OrderedSet(
                    await TweetNestApp.session.persistentContainer.performBackgroundTask { managedObjectContext in
                        let fetchResults = try? managedObjectContext.fetch(fetchRequest)

                        return fetchResults?.compactMap { $0["id"] as? String }
                    } ?? []
                )

                await MainActor.run {
                    self.filteredUserIDsByNames = filteredUserIDsByNames
                }
            }
        }
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
