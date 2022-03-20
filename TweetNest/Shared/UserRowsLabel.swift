//
//  UserRowsLabel.swift
//  TweetNest
//
//  Created by 강재홍 on 2022/03/20.
//

import SwiftUI
import TweetNestKit

struct UserRowsLabel: View {
    let userID: String

    @StateObject private var latestUserDetailsFetchedResultsController: FetchedResultsController<UserDetail>

    var body: some View {
        let latestUserDetail = latestUserDetailsFetchedResultsController.fetchedObjects.first

        Label {
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
        } icon: {
            if let latestUserDetail = latestUserDetail {
                ProfileImage(profileImageURL: latestUserDetail.profileImageURL)
                    .frame(width: 24, height: 24)
            }
        }
        #if os(watchOS)
        .labelStyle(.titleOnly)
        #endif
        .accessibilityLabel(Text(verbatim: latestUserDetail?.name ?? userID.displayUserID))
    }

    init(userID: String) {
        self.userID = userID

        self._latestUserDetailsFetchedResultsController = StateObject(
            wrappedValue: FetchedResultsController<UserDetail>(
                fetchRequest: {
                    let fetchRequest = UserDetail.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "user.id == %@", userID)
                    fetchRequest.sortDescriptors = [
                        NSSortDescriptor(keyPath: \UserDetail.user?.modificationDate, ascending: false),
                        NSSortDescriptor(keyPath: \UserDetail.creationDate, ascending: false),
                    ]
                    fetchRequest.fetchLimit = 1
                    fetchRequest.returnsObjectsAsFaults = false

                    return fetchRequest
                }(),
                managedObjectContext: TweetNestApp.session.persistentContainer.viewContext
            )
        )
    }
}

struct UserRowsLabel_Previews: PreviewProvider {
    static var previews: some View {
        UserRowsLabel(userID: "123456")
    }
}
