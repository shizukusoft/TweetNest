//
//  UserRow.swift
//  UserRow
//
//  Created by Jaehong Kang on 2021/08/09.
//

import SwiftUI
import CoreData
import TweetNestKit

struct UserRow<Icon>: View where Icon: View {
    private let userID: String
    private var displayUserID: String {
        Int64(userID).flatMap { "#\($0.twnk_formatted())" } ?? "#\(userID)"
    }

    private let user: User?

    private let icon: Icon?

    private let defaultUserDetailsPredicate: NSPredicate

    @Environment(\.account) private var account: Account?
    @Environment(\.managedObjectContext) private var viewContext

    @Binding private var searchQuery: String
    @FetchRequest private var filteredUserDetails: FetchedResults<NSManagedObjectID>
    @FetchRequest private var lastestUserDetail: FetchedResults<UserDetail>

    var body: some View {
        if let latestUserDetail = lastestUserDetail.first {
            Group {
                if searchQuery.isEmpty || filteredUserDetails.count > 0 {
                    Label {
                        Label {
                            if let user = user ?? latestUserDetail.user {
                                NavigationLink {
                                    UserView(user: user)
                                        .environment(\.account, account)
                                } label: {
                                    userLabelTitle(latestUserDetail: latestUserDetail)
                                }
                            } else {
                                userLabelTitle(latestUserDetail: latestUserDetail)
                            }
                        } icon: {
                            ProfileImage(profileImageURL: latestUserDetail.profileImageURL)
                                .frame(width: 24, height: 24)
                        }
                        #if os(watchOS)
                        .labelStyle(.titleOnly)
                        #endif
                    } icon: {
                        icon
                    }
                    .accessibilityLabel(Text(verbatim: latestUserDetail.name ?? displayUserID))
                }
            }
            .onChange(of: searchQuery) { newValue in
                filteredUserDetails.nsPredicate = filteredUserDetailsNSPredicate(searchQuery: newValue)
            }
        } else {
            if searchQuery.isEmpty || displayUserID.contains(searchQuery) {
                Label {
                    Text(verbatim: displayUserID)
                } icon: {
                    icon
                }
            }
        }
    }

    init(userID: String, user: User? = nil, searchQuery: Binding<String>, @ViewBuilder icon: () -> Icon) {
        self.userID = userID
        self.user = user

        let defaultUserDetailsPredicate: NSPredicate
        if let user = user {
            defaultUserDetailsPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "user == %@", user.objectID),
                NSPredicate(format: "user.id == %@", userID),
            ])
        } else {
            defaultUserDetailsPredicate = NSPredicate(format: "user.id == %@", userID)
        }
        self.defaultUserDetailsPredicate = defaultUserDetailsPredicate

        self._filteredUserDetails = FetchRequest(
            fetchRequest: {
                let fetchRequest = NSFetchRequest<NSManagedObjectID>()
                fetchRequest.entity = UserDetail.entity()
                fetchRequest.resultType = .managedObjectIDResultType
                fetchRequest.predicate = Self.filteredUserDetailsNSPredicate(defaultUserDetailsPredicate: defaultUserDetailsPredicate, searchQuery: searchQuery.wrappedValue)
                fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \UserDetail.creationDate, ascending: true)]

                return fetchRequest
            }(),
            animation: .default
        )

        self._lastestUserDetail = FetchRequest(
            fetchRequest: {
                let fetchRequest = UserDetail.fetchRequest()
                fetchRequest.predicate = defaultUserDetailsPredicate
                fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \UserDetail.creationDate, ascending: false)]
                fetchRequest.fetchLimit = 1
                fetchRequest.propertiesToFetch = ["name", "username", "profileImageURL"]

                return fetchRequest
            }(),
            animation: .default
        )

        self._searchQuery = searchQuery
        self.icon = icon()
    }

    init(userID: String, user: User? = nil, searchQuery: Binding<String>) where Icon == EmptyView {
        self.userID = userID
        self.user = user

        let defaultUserDetailsPredicate: NSPredicate
        if let user = user {
            defaultUserDetailsPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "user == %@", user.objectID),
                NSPredicate(format: "user.id == %@", userID),
            ])
        } else {
            defaultUserDetailsPredicate = NSPredicate(format: "user.id == %@", userID)
        }
        self.defaultUserDetailsPredicate = defaultUserDetailsPredicate

        self._filteredUserDetails = FetchRequest(
            fetchRequest: {
                let fetchRequest = NSFetchRequest<NSManagedObjectID>()
                fetchRequest.entity = UserDetail.entity()
                fetchRequest.resultType = .managedObjectIDResultType
                fetchRequest.predicate = Self.filteredUserDetailsNSPredicate(defaultUserDetailsPredicate: defaultUserDetailsPredicate, searchQuery: searchQuery.wrappedValue)
                fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \UserDetail.creationDate, ascending: true)]

                return fetchRequest
            }(),
            animation: .default
        )

        self._lastestUserDetail = FetchRequest(
            fetchRequest: {
                let fetchRequest = UserDetail.fetchRequest()
                fetchRequest.predicate = defaultUserDetailsPredicate
                fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \UserDetail.creationDate, ascending: false)]
                fetchRequest.fetchLimit = 1
                fetchRequest.propertiesToFetch = ["name", "username", "profileImageURL"]

                return fetchRequest
            }(),
            animation: .default
        )

        self._searchQuery = searchQuery
        self.icon = nil
    }

    @ViewBuilder
    func userLabelTitle(latestUserDetail: UserDetail) -> some View {
        TweetNestStack {
            Text(verbatim: latestUserDetail.name ?? displayUserID)
                .lineLimit(1)

            if let username = latestUserDetail.username {
                Text(verbatim: "@\(username)")
                    .lineLimit(1)
                    .layoutPriority(1)
                    .foregroundColor(Color.gray)
            }
        }
    }
}

extension UserRow {
    static func filteredUserDetailsNSPredicate(defaultUserDetailsPredicate: NSPredicate, searchQuery: String) -> NSPredicate {
        NSCompoundPredicate(andPredicateWithSubpredicates: [
            defaultUserDetailsPredicate,
            NSCompoundPredicate(orPredicateWithSubpredicates: [
                NSPredicate(format: "name CONTAINS[cd] %@", searchQuery),
                NSPredicate(format: "username CONTAINS[cd] %@", searchQuery),
            ])
        ])
    }

    func filteredUserDetailsNSPredicate(searchQuery: String) -> NSPredicate {
        Self.filteredUserDetailsNSPredicate(defaultUserDetailsPredicate: defaultUserDetailsPredicate, searchQuery: searchQuery)
    }
}

struct UserRow_Previews: PreviewProvider {
    static var previews: some View {
        UserRow(userID: Account.preview.user?.id ?? "1234567890", user: nil, searchQuery: .constant(""))
    }
}
