//
//  UserRows.swift
//  TweetNest
//
//  Created by 강재홍 on 2022/03/20.
//

import SwiftUI
import TweetNestKit

struct UserRows<Icon: View, UserIDs: RandomAccessCollection>: View where UserIDs.Element == String {
    @Environment(\.account) private var account: Account?

    let userIDs: UserIDs
    let icon: Icon?

    var body: some View {
        ForEach(userIDs, id: \.self) { userID in
            NavigationLink {
                UserView(userID: userID)
                    .environment(\.account, account)
            } label: {
                Label {
                    UserRowsLabel(userID: userID)
                } icon: {
                    icon
                }
            }
        }
    }

    private init(userIDs: UserIDs, icon: Icon?) {
        self.userIDs = userIDs
        self.icon = icon
    }

    init(userIDs: UserIDs, @ViewBuilder icon: () -> Icon){
        self.init(userIDs: userIDs, icon: icon())
    }

    init(userIDs: UserIDs) where Icon == EmptyView {
        self.init(userIDs: userIDs, icon: nil)
    }
}

struct UserRows_Previews: PreviewProvider {
    static var previews: some View {
        UserRows(userIDs: ["123456789"])
    }
}
