//
//  UserDataView.swift
//  UserDataView
//
//  Created by Jaehong Kang on 2021/08/04.
//

import SwiftUI
import TweetNestKit

struct UserDataView: View {
    let userData: UserData

    var body: some View {
        List {
            UserDataProfileSection(title: "Profile", userData: userData)

            Section {
                if let followingUserIDs = userData.followingUserIDs, followingUserIDs.isEmpty == false {
                    NavigationLink {
                        UsersList(userIDs: followingUserIDs)
                            .navigationTitle(Text("Followings"))
                    } label: {
                        HStack {
                            Text("Following")
                            Spacer()
                            Text(followingUserIDs.count.formatted())
                                .foregroundColor(Color.gray)
                        }
                    }
                }

                if let followerUserIDs = userData.followerUserIDs, followerUserIDs.isEmpty == false {
                    NavigationLink {
                        UsersList(userIDs: followerUserIDs)
                            .navigationTitle(Text("Followers"))
                    } label: {
                        HStack {
                            Text("Followers")
                            Spacer()
                            Text(followerUserIDs.count.formatted())
                                .foregroundColor(Color.gray)
                        }
                    }
                }
            }
        }
    }
}

//#if DEBUG
//struct UserDataView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserDataView()
//    }
//}
//#endif
