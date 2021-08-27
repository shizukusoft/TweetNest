//
//  UserRow.swift
//  UserRow
//
//  Created by Jaehong Kang on 2021/08/09.
//

import SwiftUI
import TweetNestKit

struct UserRow: View {
    @Environment(\.account) var account: Account?
    
    let placeholderName: String
    @FetchRequest private var userDetails: FetchedResults<UserDetail>

    var body: some View {
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

    init(userID: String) {
        self.placeholderName = "#\(Int64(userID)?.formatted() ?? userID)"

        let userDetailsFetchRequest = UserDetail.fetchRequest()
        userDetailsFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \UserDetail.creationDate, ascending: false)]
        userDetailsFetchRequest.predicate = NSPredicate(format: "user.id == %@", userID)
        userDetailsFetchRequest.fetchLimit = 1

        self._userDetails = FetchRequest(
            fetchRequest: userDetailsFetchRequest,
            animation: .default
        )
    }
    
    init(user: User) {
        self.placeholderName = user.id.flatMap { "#\(Int64($0)?.formatted() ?? $0)" } ?? user.objectID.description

        let userDetailsFetchRequest = UserDetail.fetchRequest()
        userDetailsFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \UserDetail.creationDate, ascending: false)]
        userDetailsFetchRequest.predicate = NSPredicate(format: "user == %@", user)
        userDetailsFetchRequest.fetchLimit = 1

        self._userDetails = FetchRequest(
            fetchRequest: userDetailsFetchRequest,
            animation: .default
        )
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

//struct UserRow_Previews: PreviewProvider {
//    static var previews: some View {
//        UserRow()
//    }
//}
