//
//  AccountLabel.swift
//  AccountLabel
//
//  Created by Jaehong Kang on 2021/09/07.
//

import SwiftUI
import TweetNestKit

struct AccountLabel: View {
    @ObservedObject var account: ManagedAccount

    @FetchRequest
    private var userDetails: FetchedResults<ManagedUserDetail>

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

    init(account: ManagedAccount) {
        self.account = account

        self._userDetails = FetchRequest(
            fetchRequest: {
                let fetchRequest = ManagedUserDetail.fetchRequest()
                fetchRequest.predicate = account.userID.flatMap { NSPredicate(format: "userID == %@", $0) } ?? NSPredicate(value: false)
                fetchRequest.sortDescriptors = [
                    NSSortDescriptor(keyPath: \ManagedUserDetail.creationDate, ascending: false)
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
