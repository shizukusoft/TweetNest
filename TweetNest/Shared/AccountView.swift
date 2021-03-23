//
//  AccountView.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/02/24.
//

import SwiftUI
import TweetNestKit

struct AccountView: View {
    let account: Account

    var body: some View {
        VStack {
            ImageView(url: URL(string: "https://abs.twimg.com/sticky/default_profile_images/default_profile_normal.png")!, placeholderImage: nil)
            Text("Hello, \(account.user?.userDatas.last?.name ?? "")!")
        }
        .navigationTitle(Text(account.user?.userDatas.last?.name ?? "#\(account.user!.id!)"))
        .toolbar(content: {
            ToolbarItem(placement: .automatic) {
                Button(action: refresh) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
            }
        })
    }

    func refresh() {

    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView(account: Account())
    }
}
