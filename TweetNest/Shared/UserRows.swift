//
//  UserRows.swift
//  TweetNest
//
//  Created by 강재홍 on 2022/03/20.
//

import SwiftUI
import CoreData
import TweetNestKit

struct UserRows<Icon: View, UserIDs: RandomAccessCollection>: View where UserIDs.Element == String {
    @Environment(\.account) private var account: Account?

    let userIDs: UserIDs
    let searchQuery: String
    let icon: Icon?

    @StateObject private var usersFetchedResultsController: FetchedResultsController<User>
    @State @Lazy private var backgroundManagedObjectContext = TweetNestApp.session.persistentContainer.newBackgroundContext()
    @State private var searchTask: Task<Void, Never>?
    @State private var filteredUserIDs: Set<String>?

    var body: some View {
        let usersByID = Dictionary(
            usersFetchedResultsController.fetchedObjects
                .lazy
                .map { ($0.id, $0) },
            uniquingKeysWith: { first, _ in first }
        )

        ForEach(userIDs, id: \.self) { userID in
            if filteredUserIDs?.contains(userID) != false {
                NavigationLink {
                    UserView(userID: userID)
                        .environment(\.account, account)
                } label: {
                    Label {
                        UserRowsLabel(userID: userID, user: usersByID[userID])
                    } icon: {
                        icon
                    }
                }
            }
        }
        .onChange(of: searchQuery) { newValue in
            let searchQuery = newValue

            guard searchQuery.isEmpty == false else {
                self.filteredUserIDs = nil
                return
            }

            let userIDs = userIDs
            let backgroundManagedObjectContext = backgroundManagedObjectContext

            searchTask?.cancel()
            searchTask = Task.detached(priority: .userInitiated) {
                let fetchRequest = NSFetchRequest<NSDictionary>()
                fetchRequest.entity = User.entity()
                fetchRequest.resultType = .dictionaryResultType
                fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                    NSPredicate(format: "id IN %@", Array(userIDs)),
                    NSCompoundPredicate(orPredicateWithSubpredicates: [
                        NSPredicate(format: "id CONTAINS[cd] %@", searchQuery),
                        NSPredicate(format: "ANY userDetails.username CONTAINS[cd] %@", searchQuery),
                        NSPredicate(format: "ANY userDetails.name CONTAINS[cd] %@", searchQuery),
                    ])
                ])
                fetchRequest.propertiesToFetch = ["id"]
                fetchRequest.returnsDistinctResults = true

                async let filteredUserIDsByNames: Set<String> = Set(
                    backgroundManagedObjectContext
                        .perform {
                            try? backgroundManagedObjectContext.fetch(fetchRequest)
                        }?
                        .compactMap { $0["id"] as? String } ?? []
                )

                guard Task.isCancelled == false else { return }

                let filteredUserIDsByUserIDs = Set(
                    userIDs
                        .lazy
                        .filter { $0.localizedCaseInsensitiveContains("searchQuery") || $0.displayUserID.localizedCaseInsensitiveContains("searchQuery") }
                )

                guard Task.isCancelled == false else { return }

                let filteredUserIDs = await filteredUserIDsByUserIDs.union(filteredUserIDsByNames)

                guard Task.isCancelled == false else { return }

                await MainActor.run {
                    self.filteredUserIDs = filteredUserIDs
                }
            }
        }
    }

    private init(userIDs: UserIDs, searchQuery: String, icon: Icon?) {
        self.userIDs = userIDs
        self.searchQuery = searchQuery
        self.icon = icon

        self._usersFetchedResultsController = StateObject(
            wrappedValue: FetchedResultsController<User>(
                fetchRequest: {
                    let fetchRequest = User.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "id IN %@", Array(userIDs))
                    fetchRequest.sortDescriptors = [
                        NSSortDescriptor(keyPath: \User.modificationDate, ascending: false),
                        NSSortDescriptor(keyPath: \User.creationDate, ascending: false),
                    ]
                    fetchRequest.returnsObjectsAsFaults = false

                    return fetchRequest
                }(),
                managedObjectContext: TweetNestApp.session.persistentContainer.viewContext
            )
        )
    }

    init(userIDs: UserIDs, searchQuery: String = "", @ViewBuilder icon: () -> Icon){
        self.init(userIDs: userIDs, searchQuery: searchQuery, icon: icon())
    }

    init(userIDs: UserIDs, searchQuery: String = "") where Icon == EmptyView {
        self.init(userIDs: userIDs, searchQuery: searchQuery, icon: nil)
    }
}

struct UserRows_Previews: PreviewProvider {
    static var previews: some View {
        UserRows(userIDs: ["123456789"])
    }
}
