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
    @Environment(\.account) private var account: ManagedAccount?

    let userIDs: UserIDs
    let searchQuery: String
    let icon: Icon?

    @State @Lazy private var backgroundManagedObjectContext = TweetNestApp.session.persistentContainer.newBackgroundContext()
    @State private var searchTask: Task<Void, Never>?
    @State private var filteredUserIDs: Set<String>?

    var body: some View {
        ForEach(userIDs, id: \.self) { userID in
            if filteredUserIDs?.contains(userID) != false {
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
                fetchRequest.entity = ManagedUserDetail.entity()
                fetchRequest.resultType = .dictionaryResultType
                fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                    NSPredicate(format: "userID IN %@", Array(userIDs)),
                    NSCompoundPredicate(orPredicateWithSubpredicates: [
                        NSPredicate(format: "userID CONTAINS[cd] %@", searchQuery),
                        NSPredicate(format: "username CONTAINS[cd] %@", searchQuery),
                        NSPredicate(format: "name CONTAINS[cd] %@", searchQuery),
                    ])
                ])
                fetchRequest.propertiesToFetch = ["userID"]
                fetchRequest.returnsDistinctResults = true

                async let filteredUserIDsByNames: Set<String> = Set(
                    backgroundManagedObjectContext
                        .perform {
                            try? backgroundManagedObjectContext.fetch(fetchRequest)
                        }?
                        .compactMap { $0["userID"] as? String } ?? []
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
    }

    init(userIDs: UserIDs, searchQuery: String = "", @ViewBuilder icon: () -> Icon) {
        self.init(userIDs: userIDs, searchQuery: searchQuery, icon: icon())
    }

    init(userIDs: UserIDs, searchQuery: String = "") where Icon == EmptyView {
        self.init(userIDs: userIDs, searchQuery: searchQuery, icon: nil)
    }
}

#if DEBUG
struct UserRows_Previews: PreviewProvider {

    static var previews: some View {
        NavigationView {
            List {
                UserRows(userIDs: ManagedUserDetail.preview.followingUserIDs!)
                .environment(\.account, .preview)
            }
            .navigationBarHidden(true)
        }
    }
}
#endif
