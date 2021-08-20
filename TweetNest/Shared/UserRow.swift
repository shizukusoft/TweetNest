//
//  UserRow.swift
//  UserRow
//
//  Created by Jaehong Kang on 2021/08/09.
//

import SwiftUI
import TweetNestKit

struct UserRow: View {
    let userID: String
    @FetchRequest private var userDetails: FetchedResults<UserDetail>

    var body: some View {
        if let latestUserDetail = userDetails.first, let user = latestUserDetail.user {
            NavigationLink {
                UserView(user: user)
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
            Text(verbatim: "#\(Int64(userID)?.formatted() ?? userID)")
        }
    }

    init(userID: String) {
        self.userID = userID

        let userDetailsFetchRequest = UserDetail.fetchRequest()
        userDetailsFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \UserDetail.creationDate, ascending: false)]
        userDetailsFetchRequest.predicate = NSPredicate(format: "user.id == %@", userID)
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
