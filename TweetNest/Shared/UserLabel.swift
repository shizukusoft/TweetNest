//
//  UserLabel.swift
//  UserLabel
//
//  Created by Jaehong Kang on 2021/09/13.
//

import SwiftUI
import TweetNestKit

struct UserLabel: View {
    @Environment(\.account) private var account: Account?

    let userID: String

    var displayUserID: String {
        Int64(userID).flatMap { "#\($0.twnk_formatted())" } ?? "#\(userID)"
    }

    @FetchRequest private var latestUserDetails: FetchedResults<UserDetail>

    var latestUserDetail: UserDetail? {
        latestUserDetails.first
    }

    var body: some View {
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
    }

    init(userID: String) {
        self.userID = userID

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

struct UserLabel_Previews: PreviewProvider {
    static var previews: some View {
        UserLabel(userID: "123456789")
    }
}
