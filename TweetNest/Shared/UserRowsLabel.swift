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

        let name = latestUserDetail?.name ?? userID.displayUserID

        Label {
            TweetNestStack {
                Text(verbatim: name)
                    .lineLimit(1)

                if latestUserDetail?.name != nil, let username = latestUserDetail?.username {
                    Text(verbatim: "@\(username)")
                        .lineLimit(1)
                        .layoutPriority(1)
                        .foregroundColor(Color.gray)
                }
            }
        } icon: {
            if let profileImageURL = latestUserDetail?.profileImageURL {
                ProfileImage(profileImageURL: profileImageURL)
                    .frame(width: 24, height: 24)
            }
        }
        #if os(watchOS)
        .labelStyle(.titleOnly)
        #endif
        .accessibilityLabel(Text(verbatim: name))
    }

    init(userID: String) {
        self.userID = userID

        self._latestUserDetailsFetchedResultsController = StateObject(
            wrappedValue: FetchedResultsController<UserDetail>(
                fetchRequest: {
                    let fetchRequest = UserDetail.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "user.id == %@", userID)
                    fetchRequest.sortDescriptors = [
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
