//
//  UserRow.swift
//  UserRow
//
//  Created by Jaehong Kang on 2021/08/09.
//

import SwiftUI
import TweetNestKit

struct UserRow<Icon>: View where Icon: View {
    let icon: Icon?

    @Environment(\.account) private var account: Account?
    
    private let placeholderName: String
    @FetchRequest private var userDetails: FetchedResults<UserDetail>

    @Binding var searchQuery: String

    private var searchResult: Bool {
        guard let userDetail = userDetails.first else {
            return placeholderName.contains(searchQuery)
        }

        return userDetail.name?.localizedCaseInsensitiveContains(searchQuery) == true ||
            userDetail.username?.localizedCaseInsensitiveContains(searchQuery) == true ||
            userDetail.user?.userDetails?.contains(
                where: {
                    ($0 as? UserDetail)?.name?.localizedCaseInsensitiveContains(searchQuery) == true ||
                    ($0 as? UserDetail)?.username?.localizedCaseInsensitiveContains(searchQuery) == true
                }
            ) == true
    }

    @ViewBuilder
    var userView: some View {
        if let latestUserDetail = userDetails.first, let user = latestUserDetail.user {
            NavigationLink {
                UserView(user: user)
                    .environment(\.account, account)
            } label: {
                Label {
                    #if os(watchOS)
                    VStack(alignment: .leading, spacing: nil) {
                        userLabelTitle(latestUserDetail: latestUserDetail, user: user)
                    }
                    #else
                    HStack(spacing: nil) {
                        userLabelTitle(latestUserDetail: latestUserDetail, user: user)
                    }
                    #endif
                } icon: {
                    ProfileImage(userDetail: latestUserDetail)
                        .frame(width: 24, height: 24)
                }
                #if os(watchOS)
                .labelStyle(.titleOnly)
                #endif
            }
            .accessibilityLabel(Text(verbatim: latestUserDetail.name ?? user.id.flatMap { "#\($0)" } ?? user.objectID.description))
        } else {
            Text(verbatim: placeholderName)
        }
    }

    var body: some View {
        if searchQuery.isEmpty || searchResult {
            if let icon = icon {
                Label {
                    userView
                } icon: {
                    icon
                }
            } else {
                userView
            }
        }
    }

    private init(placeholderName: String, predicate: NSPredicate, searchQuery: Binding<String>, @ViewBuilder icon: () -> Icon) {
        self.placeholderName = placeholderName

        let userDetailsFetchRequest = UserDetail.fetchRequest()
        userDetailsFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \UserDetail.creationDate, ascending: false)]
        userDetailsFetchRequest.predicate = predicate
        userDetailsFetchRequest.fetchLimit = 1

        self._userDetails = FetchRequest(
            fetchRequest: userDetailsFetchRequest,
            animation: .default
        )

        self._searchQuery = searchQuery

        self.icon = icon()
    }

    private init(placeholderName: String, predicate: NSPredicate, searchQuery: Binding<String>) where Icon == EmptyView {
        self.placeholderName = placeholderName

        let userDetailsFetchRequest = UserDetail.fetchRequest()
        userDetailsFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \UserDetail.creationDate, ascending: false)]
        userDetailsFetchRequest.predicate = predicate
        userDetailsFetchRequest.fetchLimit = 1

        self._userDetails = FetchRequest(
            fetchRequest: userDetailsFetchRequest,
            animation: .default
        )

        self._searchQuery = searchQuery

        self.icon = nil
    }
    
    @ViewBuilder
    func userLabelTitle(latestUserDetail: UserDetail, user: User) -> some View {
        Text(verbatim: latestUserDetail.name ?? user.id.flatMap { "#\($0)" } ?? user.objectID.description)
            .lineLimit(1)

        if let username = latestUserDetail.username {
            Text(verbatim: "@\(username)")
                .lineLimit(1)
                .layoutPriority(1)
                .foregroundColor(Color.gray)
        }
    }
}

extension UserRow {
    init(userID: String, searchQuery: Binding<String>, @ViewBuilder icon: () -> Icon) {
        self.init(
            placeholderName: "#\(Int64(userID)?.twnk_formatted() ?? userID)",
            predicate: NSPredicate(format: "user.id == %@", userID),
            searchQuery: searchQuery,
            icon: icon
        )
    }

    init(user: User, searchQuery: Binding<String>, @ViewBuilder icon: () -> Icon) {
        self.init(
            placeholderName: user.id.flatMap { "#\(Int64($0)?.twnk_formatted() ?? $0)" } ?? user.objectID.description,
            predicate: NSPredicate(format: "user == %@", user),
            searchQuery: searchQuery,
            icon: icon
        )
    }
}

extension UserRow where Icon == EmptyView {
    init(userID: String, searchQuery: Binding<String>) {
        self.init(
            placeholderName: "#\(Int64(userID)?.twnk_formatted() ?? userID)",
            predicate: NSPredicate(format: "user.id == %@", userID),
            searchQuery: searchQuery
        )
    }

    init(user: User, searchQuery: Binding<String>) {
        self.init(
            placeholderName: user.id.flatMap { "#\(Int64($0)?.twnk_formatted() ?? $0)" } ?? user.objectID.description,
            predicate: NSPredicate(format: "user == %@", user),
            searchQuery: searchQuery
        )
    }
}

//struct UserRow_Previews: PreviewProvider {
//    static var previews: some View {
//        UserRow()
//    }
//}
