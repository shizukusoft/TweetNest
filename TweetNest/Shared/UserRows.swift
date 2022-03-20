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
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.account) private var account: Account?

    let userIDs: OrderedSet<String>
    let searchQuery: String

    let icon: Icon?

    private var filteredUserIDs: OrderedSet<String> {
        guard searchQuery.isEmpty == false else {
            return userIDs
        }

        var filteredUserIDs = userIDs.filter { $0.localizedCaseInsensitiveContains(searchQuery) || $0.displayUserID.localizedCaseInsensitiveContains(searchQuery) }

        let fetchRequest = NSFetchRequest<NSDictionary>()
        fetchRequest.entity = User.entity()
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "id IN %@", Array(userIDs.subtracting(filteredUserIDs))),
            NSCompoundPredicate(orPredicateWithSubpredicates: [
                NSPredicate(format: "userDetails.username CONTAINS[cd] %@", searchQuery),
                NSPredicate(format: "userDetails.name CONTAINS[cd] %@", searchQuery),
            ])
        ])
        fetchRequest.propertiesToFetch = ["id"]

        let fetchResults = try? viewContext.fetch(fetchRequest)
        filteredUserIDs.append(contentsOf: fetchResults?.compactMap { $0["id"] as? String } ?? [])

        return userIDs.intersection(filteredUserIDs)
    }

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
    }

    private init<S>(userIDs: S, searchQuery: String = "", icon: Icon?) where S: Sequence, S.Element == String {
        self.userIDs = OrderedSet(userIDs)
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
