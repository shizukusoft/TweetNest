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

    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            ProfileImage(profileImageURL: account.user?.sortedUserDetails?.last?.profileImageURL)
                #if os(watchOS)
                .frame(width: 16, height: 16)
                #else
                .frame(width: 24, height: 24)
                #endif

            Text(verbatim: account.user?.displayUsername ?? account.objectID.description)
        }
    }
}

struct AccountLabel_Previews: PreviewProvider {
    static var previews: some View {
        AccountLabel(account: .preview)
    }
}
