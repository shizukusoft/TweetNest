//
//  UserView.swift
//  UserView
//
//  Created by Jaehong Kang on 2021/08/02.
//

import SwiftUI
import TweetNestKit

struct UserView: View {
    @ObservedObject var user: User

    var lastUserData: UserData? {
        user.sortedUserDatas?.last
    }

    @State var showErrorAlert: Bool = false
    @State var error: Error? = nil

    #if os(iOS)
    @State var safariSheetURL: URL? = nil

    @Environment(\.openURL) private var openURL
    #endif

    var body: some View {
        List {
            if let lastUserData = lastUserData {
                Section {
                    UserDataProfileView(userData: lastUserData)
                } header: {
                    Text("Latest Profile")
                } footer: {
                    VStack(alignment: .leading) {
                        Text(verbatim: "#\(Int64(user.id)?.formatted() ?? user.id)")
                        if let lastUpdateDate = user.lastUpdateEndDate {
                            Text("Updated \(lastUpdateDate, style: .relative) ago")
                            .accessibilityAddTraits(.updatesFrequently)
                        }
                    }
                }
            }
            UserAllDataSection(user: user)
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .navigationTitle(Text(verbatim: lastUserData?.username.flatMap({"@\($0)"}) ?? "#\(user.id)"))
        .toolbar {
            let userProfileURL = URL(string: "https://twitter.com/intent/user?user_id=\(user.id)")!
            ToolbarItemGroup(placement: .automatic) {
                #if os(iOS)
                Button {
                    safariSheetURL = userProfileURL
                } label: {
                    Label("Open Profile", systemImage: "safari")
                }
                .contextMenu {
                    Button("Open Profile") {
                        openURL(userProfileURL)
                    }
                }
                #else
                Link(destination: userProfileURL) {
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
