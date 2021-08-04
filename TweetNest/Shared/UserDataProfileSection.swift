//
//  UserDataProfileSection.swift
//  UserDataProfileSection
//
//  Created by Jaehong Kang on 2021/08/03.
//

import SwiftUI
import TweetNestKit

struct UserDataProfileSection<Title>: View where Title: StringProtocol{
    let title: Title
    let userData: UserData

    var body: some View {
        Section(title) {
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

                if let userAttributedDescription = userData.userAttributedDescription.flatMap({AttributedString($0)}), userAttributedDescription.startIndex != userAttributedDescription.endIndex {
                    Text(userAttributedDescription)
                }
            }
            .padding([.top, .bottom], 8)

            if let location = userData.location {
                HStack {
                    Label("Location", systemImage: "location")
                    Spacer()
                    if let locationQueryURL = location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed).flatMap({ URL(string: "http://maps.apple.com/?q=\($0)") }) {
                        Link(location, destination: locationQueryURL)
                    } else {
                        Text(location)
                    }
                }
            }

            if let url = userData.url {
                HStack {
                    Label("URL", systemImage: "safari")
                    Spacer()
                    Link(url.absoluteString, destination: url)
                }
            }

            if let creationDate = userData.creationDate {
                HStack {
                    Label("Joined", systemImage: "calendar")
                    Spacer()
                    Text(creationDate.formatted(date: .numeric, time: .standard))
                }
            }

            if userData.isProtected {
                Label("Protected", systemImage: "lock")
            }

            if userData.isVerified {
                Label("Verified", systemImage: "checkmark.seal")
            }
        }
    }
}

//#if DEBUG
//struct UserProfileSection_Previews: PreviewProvider {
//    static var previews: some View {
//        UserDataProfileSection(userData: nil)
//    }
//}
//#endif
