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
    fileprivate var displayUserID: String {
        Int64(self).flatMap { "#\($0.twnk_formatted())" } ?? "#\(self)"
    }
}

struct UserRows<Icon: View>: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.account) private var account: Account?

    let userIDs: OrderedSet<String>
    @Binding var searchQuery: String

    let icon: Icon?

    @StateObject private var latestUserDetailsFetchedResultsController: FetchedResultsController<UserDetail>

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

        filteredUserIDs.append(contentsOf: (try? viewContext.fetch(fetchRequest).compactMap { $0["id"] as? String }) ?? [])

        return userIDs.intersection(filteredUserIDs)
    }

    var body: some View {
        let latestUserDetailsByUserID = Dictionary(grouping: latestUserDetailsFetchedResultsController.fetchedObjects) {
            $0.user?.id
        }

        ForEach(filteredUserIDs, id: \.self) { userID in
            let latestUserDetail = latestUserDetailsByUserID[userID]?.last

            Label {
                Label {
                    NavigationLink {
                        UserView(userID: userID)
                            .environment(\.account, account)
                    } label: {
                        if let latestUserDetail = latestUserDetail {
                            TweetNestStack {
                                Text(verbatim: latestUserDetail.name ?? userID.displayUserID)
                                    .lineLimit(1)

                                if let username = latestUserDetail.username {
                                    Text(verbatim: "@\(username)")
                                        .lineLimit(1)
                                        .layoutPriority(1)
                                        .foregroundColor(Color.gray)
                                }
                            }
                        } else {
                            Text(verbatim: userID.displayUserID)
                                .lineLimit(1)
                        }
                    }
                } icon: {
                    if let latestUserDetail = latestUserDetail {
                        ProfileImage(profileImageURL: latestUserDetail.profileImageURL)
                            .frame(width: 24, height: 24)
                    }
                }
                #if os(watchOS)
                .labelStyle(.titleOnly)
                #endif
            } icon: {
                icon
            }
            .accessibilityLabel(Text(verbatim: latestUserDetail?.name ?? userID.displayUserID))
        }
    }

    private init<S>(userIDs: S, searchQuery: Binding<String> = .constant(""), icon: Icon?) where S: Sequence, S.Element == String {
        self.userIDs = OrderedSet(userIDs)
        self._searchQuery = searchQuery
        self.icon = icon

        self._latestUserDetailsFetchedResultsController = StateObject(
            wrappedValue: FetchedResultsController<UserDetail>(
                fetchRequest: {
                    let fetchRequest = UserDetail.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "user.id IN %@", Array(userIDs))
                    fetchRequest.sortDescriptors = [
                        NSSortDescriptor(keyPath: \UserDetail.user?.modificationDate, ascending: false),
                        NSSortDescriptor(keyPath: \UserDetail.creationDate, ascending: false),
                    ]
                    fetchRequest.relationshipKeyPathsForPrefetching = ["user"]

                    return fetchRequest
                }(),
                managedObjectContext: TweetNestApp.session.persistentContainer.viewContext
            )
        )
    }

    init<S>(userIDs: S, searchQuery: Binding<String> = .constant(""), @ViewBuilder icon: () -> Icon) where S: Sequence, S.Element == String {
        self.init(userIDs: userIDs, searchQuery: searchQuery, icon: icon())
    }

    init<S>(userIDs: S, searchQuery: Binding<String> = .constant("")) where S: Sequence, S.Element == String, Icon == EmptyView {
        self.init(userIDs: userIDs, searchQuery: searchQuery, icon: nil)
    }
}

struct UserRows_Previews: PreviewProvider {
    static var previews: some View {
        UserRows(userIDs: ["123456789"])
    }
}
