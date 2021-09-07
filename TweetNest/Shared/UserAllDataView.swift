//
//  UserAllDataView.swift
//  UserAllDataView
//
//  Created by Jaehong Kang on 2021/09/07.
//

import SwiftUI
import TweetNestKit

struct UserAllDataView: View {
    @Environment(\.account) var account: Account?
    @ObservedObject var user: User

    @FetchRequest
    private var userDetails: FetchedResults<UserDetail>

    var body: some View {
        #if os(macOS)
        Table(userDetails) {
            TableColumn("Date") { userDetail in
                Text(userDetail.creationDate?.formatted(date: .abbreviated, time: .standard) ?? "")
            }
            TableColumn("Profile Image") { userDetail in
                ProfileImage(userDetail: userDetail)
                    .frame(width: 24, height: 24)
            }
            TableColumn("Name") { userDetail in
                Text(userDetail.name ?? "")
            }
            TableColumn("Username") { userDetail in
                Text(userDetail.username ?? "")
            }
            TableColumn("Location") { userDetail in
                Text(userDetail.location ?? "")
            }
            TableColumn("URL") { userDetail in
                if let url = userDetail.url {
                    Link(url.absoluteString, destination: url)
                } else {
                    Text("")
                }
            }
            TableColumn("Followings") { userDetail in
                Text(userDetail.followingUsersCount.twnk_formatted())
            }
            TableColumn("Followers") { userDetail in
                Text(userDetail.followerUsersCount.twnk_formatted())
            }

            TableColumn("Listed") { userDetail in
                Text(userDetail.listedCount.twnk_formatted())
            }
            TableColumn("Tweets") { userDetail in
                Text(userDetail.tweetsCount.twnk_formatted())
            }
        }
        #else
        Section(Text("All Data")) {
            ForEach(userDetails) { userDetail in
                NavigationLink(
                    Text(userDetail.creationDate?.formatted(date: .abbreviated, time: .standard) ?? userDetail.objectID.description))
                {
                    UserDetailView(userDetail: userDetail)
                        .navigationTitle(
                            Text(userDetail.creationDate?.formatted(date: .abbreviated, time: .standard) ?? userDetail.objectID.description)
                            .accessibilityLabel(Text(userDetail.creationDate?.formatted(date: .complete, time: .standard) ?? userDetail.objectID.description))
                        )
                        .environment(\.account, account)
                }
            }
        }
        #endif
    }

    init(user: User) {
        self.user = user
        self._userDetails = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \User.creationDate, ascending: false)],
            predicate: NSPredicate(format: "user == %@", user),
            animation: .default
        )
    }
}

struct UserAllDataView_Previews: PreviewProvider {
    static var previews: some View {
        UserAllDataView(user: Account.preview.user!)
    }
}
