//
//  UserDataProfileView.swift
//  UserDataProfileView
//
//  Created by Jaehong Kang on 2021/08/03.
//

import SwiftUI
import TweetNestKit

struct UserDataProfileView: View {
    @ObservedObject var userData: UserData

    @Environment(\.openURL) private var openURL

    var body: some View {
        Group {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 8) {
                    ProfileImage(userData: userData)
                        .frame(width: 50, height: 50)

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
                        .frame(maxHeight: .infinity)
                }
            }
            .padding([.top, .bottom], 8)

            if let location = userData.location {
                let locationQueryURL = location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed).flatMap({ URL(string: "http://maps.apple.com/?q=\($0)") })
                HStack {
                    Label("Location", systemImage: "location")
                    Spacer()
                    if let locationQueryURL = locationQueryURL {
                        Link(location, destination: locationQueryURL)
                    }
                    else {
                        Text(location)
                    }
                }
                .accessibilityElement(children: .combine)
            }

            if let url = userData.url {
                HStack {
                    Label("URL", systemImage: "safari")
                    Spacer()
                    Link(url.absoluteString, destination: url)
                }
                .accessibilityElement(children: .combine)
            }

            if let userCreationDate = userData.userCreationDate {
                HStack {
                    Label("Joined", systemImage: "calendar")
                    Spacer()
                    Text(userCreationDate.formatted(date: .numeric, time: .standard))
                }
                .accessibilityElement(children: .combine)
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
//        UserDataProfileView(userData: nil)
//    }
//}
//#endif
