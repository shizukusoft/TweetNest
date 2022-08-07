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

    @StateObject private var latestUserDetailsFetchedResultsController: FetchedResultsController<ManagedUserDetail>

    var body: some View {
        let latestUserDetail = latestUserDetailsFetchedResultsController.fetchedObjects.first

        UserDetailLabel(userDetail: latestUserDetail, placeholder: userID.displayUserID)
            #if os(watchOS)
            .labelStyle(.titleOnly)
            #else
            .labelStyle(.userDetailLabelStyle(iconWidth: 24, iconHeight: 24))
            #endif
    }

    init(userID: String) {
        self.userID = userID

        self._latestUserDetailsFetchedResultsController = StateObject(
            wrappedValue: FetchedResultsController<ManagedUserDetail>(
                fetchRequest: {
                    let fetchRequest = ManagedUserDetail.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "userID == %@", userID)
                    fetchRequest.sortDescriptors = [
                        NSSortDescriptor(keyPath: \ManagedUserDetail.creationDate, ascending: false),
                    ]
                    fetchRequest.fetchLimit = 1
                    fetchRequest.propertiesToFetch = ["name", "username", "profileImageURL"]
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
