//
//  UserRows.swift
//  TweetNest
//
//  Created by 강재홍 on 2022/03/20.
//

import SwiftUI
import CoreData
import OrderedCollections
import TweetNestKit

extension String {
    var displayUserID: String {
        Int64(self).flatMap { "#\($0.twnk_formatted())" } ?? "#\(self)"
    }
}

struct UserRows<Icon: View>: View {
    @Environment(\.account) private var account: Account?

    let userIDs: OrderedSet<String>
    let icon: Icon?

    let searchQuery: String
    @State private var managedObjectContext = TweetNestApp.session.persistentContainer.newBackgroundContext()
    @State private var filteredUserIDs: OrderedSet<String>

    var body: some View {
        ForEach(filteredUserIDs, id: \.self) { userID in
            NavigationLink {
                UserView(userID: userID)
                    .environment(\.account, account)
            } label: {
                Label {
                    UserRowsLabel(userID: userID)
                } icon: {
                    icon
                }
            }
        }
        .onChange(of: searchQuery) { newValue in
            let searchQuery = newValue
            let userIDs = self.userIDs

            Task.detached(priority: .userInitiated) {
                let filteredUserIDsByUserID = userIDs.filter { $0.localizedCaseInsensitiveContains(searchQuery) || $0.displayUserID.localizedCaseInsensitiveContains(searchQuery) }

                let fetchRequest = NSFetchRequest<NSDictionary>()
                fetchRequest.entity = User.entity()
                fetchRequest.resultType = .dictionaryResultType
                fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                    NSPredicate(format: "id IN %@", Array(userIDs.subtracting(filteredUserIDsByUserID))),
                    NSCompoundPredicate(orPredicateWithSubpredicates: [
                        NSPredicate(format: "userDetails.username CONTAINS[cd] %@", searchQuery),
                        NSPredicate(format: "userDetails.name CONTAINS[cd] %@", searchQuery),
                    ])
                ])
                fetchRequest.propertiesToFetch = ["id"]

                let filteredUserIDsByNames: [String] = await self.managedObjectContext.perform(schedule: .enqueued) {
                    let fetchResults = try? managedObjectContext.fetch(fetchRequest)

                    return fetchResults?.compactMap { $0["id"] as? String }
                } ?? []

                let filteredUserIDs = userIDs.intersection(filteredUserIDsByUserID + filteredUserIDsByNames)

                self.filteredUserIDs = filteredUserIDs
            }
        }
    }

    private init<S>(userIDs: S, searchQuery: String = "", icon: Icon?) where S: Sequence, S.Element == String {
        self.userIDs = OrderedSet(userIDs)
        self._filteredUserIDs = State(initialValue: OrderedSet(userIDs))
        self.searchQuery = searchQuery
        self.icon = icon
    }

    init<S>(userIDs: S, searchQuery: String = "", @ViewBuilder icon: () -> Icon) where S: Sequence, S.Element == String {
        self.init(userIDs: userIDs, searchQuery: searchQuery, icon: icon())
    }

    init<S>(userIDs: S, searchQuery: String = "") where S: Sequence, S.Element == String, Icon == EmptyView {
        self.init(userIDs: userIDs, searchQuery: searchQuery, icon: nil)
    }
}

struct UserRows_Previews: PreviewProvider {
    static var previews: some View {
        UserRows(userIDs: ["123456789"])
    }
}
