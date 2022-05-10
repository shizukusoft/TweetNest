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

        UserDetailLabel(userDetail: userDetail, account: account)
            #if os(watchOS)
            .labelStyle(.userDetailLabelStyle(iconWidth: 16, iconHeight: 16))
            #elseif os (macOS)
            .labelStyle(.userDetailLabelStyle(iconWidth: 18, iconHeight: 18))
            #else
            .labelStyle(.userDetailLabelStyle(iconWidth: 24, iconHeight: 24))
            #endif
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
                fetchRequest.returnsObjectsAsFaults = false

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
