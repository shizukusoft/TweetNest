//
//  UserDataView.swift
//  UserDataView
//
//  Created by Jaehong Kang on 2021/08/04.
//

import SwiftUI
import TweetNestKit

struct UserDataView: View {
    @ObservedObject var userData: UserData

    var body: some View {
        List {
            Section("Profile") {
                UserDataProfileView(userData: userData)
            }

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

                if let blockingUserIDs = userData.blockingUserIDs, blockingUserIDs.isEmpty == false {
                    NavigationLink {
                        UsersList(userIDs: blockingUserIDs)
                            .navigationTitle(Text("Blockings"))
                    } label: {
                        HStack {
                            Text("Blockings")
                            Spacer()
                            Text(blockingUserIDs.count.formatted())
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
