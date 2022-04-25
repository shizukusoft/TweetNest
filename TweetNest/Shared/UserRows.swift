//
//  UserRows.swift
//  TweetNest
//
//  Created by 강재홍 on 2022/03/20.
//

import SwiftUI
import TweetNestKit

struct UserRows<Icon: View, UserIDs: RandomAccessCollection>: View where UserIDs.Element == String {
    @Environment(\.account) private var account: Account?

    @StateObject private var usersFetchedResultsController: FetchedResultsController<User>

    let userIDs: UserIDs
    let icon: Icon?

    var body: some View {
        let usersByID = Dictionary(
            usersFetchedResultsController.fetchedObjects
                .lazy
                .map { ($0.id, $0) },
            uniquingKeysWith: { first, _ in first }
        )

        ForEach(userIDs, id: \.self) { userID in
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

    private init(userIDs: UserIDs, icon: Icon?) {
        self.userIDs = userIDs
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

    init(userIDs: UserIDs, @ViewBuilder icon: () -> Icon){
        self.init(userIDs: userIDs, icon: icon())
    }

    init(userIDs: UserIDs) where Icon == EmptyView {
        self.init(userIDs: userIDs, icon: nil)
    }
}

struct UserRows_Previews: PreviewProvider {
    static var previews: some View {
        UserRows(userIDs: ["123456789"])
    }
}
