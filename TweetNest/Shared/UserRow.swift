//
//  UserRow.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/09/23.
//

import SwiftUI
import TweetNestKit

struct UserRow: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.account) private var account: Account?

    let userID: String
    let searchQuery: String?

    private var displayUserID: String {
        Int64(userID).flatMap { "#\($0.twnk_formatted())" } ?? "#\(userID)"
    }

    @FetchRequest private var latestUserDetails: FetchedResults<UserDetail>

    private var latestUserDetail: UserDetail? {
        latestUserDetails.first
    }

    private var shouldBeHidden: Bool {
        guard let searchQuery = searchQuery, searchQuery.isEmpty == false else {
            return false
        }

        guard
            userID.localizedCaseInsensitiveContains(searchQuery) == false &&
                displayUserID.localizedCaseInsensitiveContains(searchQuery)
        else {
            return false
        }

        let fetchRequest = UserDetail.fetchRequest()
        fetchRequest.resultType = .countResultType
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "user.id == %@", userID),
            NSCompoundPredicate(orPredicateWithSubpredicates: [
                NSPredicate(format: "username CONTAINS[cd] %@", searchQuery),
                NSPredicate(format: "name CONTAINS[cd] %@", searchQuery),
            ])
        ])

        guard
            let count = try? viewContext.count(for: fetchRequest),
            count > 0
        else {
            return false
        }

        return true
    }

    var body: some View {
        if shouldBeHidden == false {
            Group {
                if let latestUserDetail = latestUserDetail {
                    Label {
                        NavigationLink {
                            UserView(userID: userID)
                                .environment(\.account, account)
                        } label: {
                            userLabelTitle(latestUserDetail: latestUserDetail, displayUserID: displayUserID)
                        }
                    } icon: {
                        ProfileImage(profileImageURL: latestUserDetail.profileImageURL)
                            .frame(width: 24, height: 24)
                    }
                } else {
                    NavigationLink {
                        UserView(userID: userID)
                            .environment(\.account, account)
                    } label: {
                        Text(verbatim: displayUserID)
                            .lineLimit(1)
                    }
                }
            }
            .accessibilityLabel(Text(verbatim: latestUserDetail?.name ?? displayUserID))
            #if os(watchOS)
            .labelStyle(.titleOnly)
            #endif
        }
    }

    init(userID: String, searchQuery: String? = nil) {
        self.userID = userID
        self.searchQuery = searchQuery

        self._latestUserDetails = FetchRequest(fetchRequest: {
            let fetchRequest = UserDetail.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "user.id == %@", userID)
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(keyPath: \UserDetail.creationDate, ascending: false),
            ]
            fetchRequest.fetchLimit = 1
            fetchRequest.relationshipKeyPathsForPrefetching = ["user"]
            fetchRequest.returnsObjectsAsFaults = false

            return fetchRequest
        }())
    }

    @ViewBuilder
    private func userLabelTitle(latestUserDetail: UserDetail, displayUserID: String) -> some View {
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

struct UserRow_Previews: PreviewProvider {
    static var previews: some View {
        UserRow(userID: "123456789")
    }
}
