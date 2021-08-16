//
//  SettingsAccountView.swift
//  SettingsAccountView
//
//  Created by Jaehong Kang on 2021/08/16.
//

import SwiftUI
import TweetNestKit

struct SettingsAccountView: View {
    @ObservedObject var account: Account
    
    var body: some View {
        Form {
            Toggle(isOn: $account.preferences.fetchBlockingUsers) {
                Text("Fetch Blocking Users")
            }
        }
        .navigationTitle(
            Text(verbatim: account.user?.sortedUserDatas?.last?.username.flatMap({"@\($0)"}) ?? "#\(account.id.formatted())")
        )
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct SettingsAccountView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsAccountView(account: .preview)
    }
}
