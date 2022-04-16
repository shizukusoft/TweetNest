//
//  AccountLabel.swift
//  AccountLabel
//
//  Created by Jaehong Kang on 2021/09/07.
//

import SwiftUI
import TweetNestKit

struct AccountLabel: View {
    @ObservedObject var account: Account

    @FetchRequest
    private var userDetails: FetchedResults<UserDetail>

    var body: some View {
        let userDetail = userDetails.first

        HStack(alignment: .center, spacing: 6) {
            ProfileImage(profileImageURL: userDetail?.profileImageURL)
                #if os(watchOS)
                .frame(width: 16, height: 16)
                #else
                .frame(width: 24, height: 24)
                #endif

            Text(verbatim: userDetail?.displayUsername ?? account.displayUserID ?? account.objectID.uriRepresentation().absoluteString)
        }
        .onChange(of: account.userID) { newValue in
            userDetails.nsPredicate = NSPredicate(format: "user.id == %@", newValue ?? "")
        }
    }

    init(account: Account) {
        self.account = account

        self._userDetails = FetchRequest(
            fetchRequest: {
                let fetchRequest = UserDetail.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "user.id == %@", account.userID ?? "")
                fetchRequest.sortDescriptors = [
                    NSSortDescriptor(keyPath: \UserDetail.user?.modificationDate, ascending: false),
                    NSSortDescriptor(keyPath: \UserDetail.creationDate, ascending: false)
                ]
                fetchRequest.fetchLimit = 1
                fetchRequest.propertiesToFetch = ["username", "profileImageURL"]

                return fetchRequest
            }()
        )
    }
}

struct AccountLabel_Previews: PreviewProvider {
    static var previews: some View {
        AccountLabel(account: .preview)
    }
}
