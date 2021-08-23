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
                HStack(spacing: 8) {
                    ProfileImage(userDetail: latestUserDetail)
                        .frame(width: 24, height: 24)

                    HStack(spacing: 4) {
                        Text(verbatim: latestUserDetail.name ?? user.id.flatMap { "#\($0)" } ?? user.description)
                            .lineLimit(1)

                        if let username = latestUserDetail.username {
                            Text(verbatim: "@\(username)")
                                .lineLimit(1)
                                .foregroundColor(Color.gray)
                                .layoutPriority(1)
                        }
                    }
                }
            }
            .accessibilityLabel(Text(verbatim: latestUserDetail.name ?? user.id.flatMap { "#\($0)" } ?? user.description))
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
        self.placeholderName = user.id.flatMap { "#\(Int64($0)?.formatted() ?? $0)" } ?? user.description

        let userDetailsFetchRequest = UserDetail.fetchRequest()
        userDetailsFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \UserDetail.creationDate, ascending: false)]
        userDetailsFetchRequest.predicate = NSPredicate(format: "user == %@", user)
        userDetailsFetchRequest.fetchLimit = 1

        self._userDetails = FetchRequest(
            fetchRequest: userDetailsFetchRequest,
            animation: .default
        )
    }
}

//struct UserRow_Previews: PreviewProvider {
//    static var previews: some View {
//        UserRow()
//    }
//}
