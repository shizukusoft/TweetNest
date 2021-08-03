//
//  UserProfileSection.swift
//  UserProfileSection
//
//  Created by Jaehong Kang on 2021/08/03.
//

import SwiftUI
import TweetNestKit

struct UserProfileSection: View {
    let userData: UserData?

    var body: some View {
        if let userData = userData {
            Section("Profile") {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 8) {
                        Group {
                            if let profileImage = Image(data: userData.profileImageData) {
                                profileImage
                                    .resizable()
                            } else {
                                Color.gray
                            }
                        }
                        .frame(width: 50, height: 50)
                        .cornerRadius(25)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(userData.name ?? userData.user.flatMap { "#\($0.id)" } ?? "")
                            if let username = userData.username {
                                Text("@\(username)")
                                    .foregroundColor(.gray)
                            }
                        }
                    }

                    if let userDescription = userData.userDescription {
                        Text(userDescription)
                    }
                }
                .padding([.top, .bottom], 8)

                if let followingUsersCount = userData.followingUserIDs?.count {
                    HStack {
                        Text("Following")
                        Spacer()
                        Text(followingUsersCount.formatted())
                            .foregroundColor(Color.gray)
                    }
                }

                if let followerUsersCount = userData.followerUserIDs?.count {
                    HStack {
                        Text("Followers")
                        Spacer()
                        Text(followerUsersCount.formatted())
                            .foregroundColor(Color.gray)
                    }
                }
            }
        } else {
            EmptyView()
        }

    }
}

#if DEBUG
struct UserProfileSection_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileSection(userData: nil)
    }
}
#endif
