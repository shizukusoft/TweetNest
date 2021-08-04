//
//  UserView.swift
//  UserView
//
//  Created by Jaehong Kang on 2021/08/02.
//

import SwiftUI
import TweetNestKit

struct UserView: View {
    let user: User

    var lastUserData: UserData? {
        user.sortedUserDatas?.last
    }

    @State var showErrorAlert: Bool = false
    @State var error: Error? = nil

    #if os(iOS)
    @State var safariSheetURL: URL? = nil
    #endif

    var body: some View {
        List {
            if let lastUserData = lastUserData {
                UserDataProfileSection(title: "Latest Profile", userData: lastUserData)
            }
            UserAllDataSection(user: user)
        }
        .navigationTitle(Text(lastUserData?.name ?? "#\(user.id)"))
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                #if os(iOS)
                Button {
                    safariSheetURL = URL(string: "https://www.twitter.com/\(lastUserData?.username ?? user.id)")!
                } label: {
                    Label("Open Profile", systemImage: "safari")
                }
                #else
                Link(destination: URL(string: "https://www.twitter.com/\(lastUserData?.username ?? user.id)")!) {
                    Label("Open Profile", systemImage: "safari")
                }
                #endif
            }
        }
        #if os(iOS)
        .sheet(item: $safariSheetURL) {
            SafariView(url: $0)
        }
        #endif
    }
}

#if DEBUG
struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView(user: Account.preview.user!)
    }
}
#endif
