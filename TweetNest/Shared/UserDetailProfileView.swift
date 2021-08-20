//
//  UserDetailProfileView.swift
//  UserDetailProfileView
//
//  Created by Jaehong Kang on 2021/08/03.
//

import SwiftUI
import TweetNestKit

struct UserDetailProfileView: View {
    @ObservedObject var userDetail: UserDetail

    @Environment(\.openURL) private var openURL

    var body: some View {
        Group {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 8) {
                    ProfileImage(userDetail: userDetail)
                        .frame(width: 50, height: 50)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(verbatim: userDetail.name ?? userDetail.user?.id.flatMap({"#\($0)"}) ?? "")
                        if let username = userDetail.username {
                            Text(verbatim: "@\(username)")
                                .foregroundColor(.gray)
                        }
                    }
                }

                if let userAttributedDescription = userDetail.userAttributedDescription.flatMap({AttributedString($0)}), userAttributedDescription.startIndex != userAttributedDescription.endIndex {
                    Text(userAttributedDescription)
                        .frame(maxHeight: .infinity)
                }
            }
            .padding([.top, .bottom], 8)

            if let location = userDetail.location {
                let locationQueryURL = location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed).flatMap({ URL(string: "http://maps.apple.com/?q=\($0)") })
                HStack {
                    Label(Text("Location"), systemImage: "location")
                    .accessibilityLabel(Text("Location"))
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

            if let url = userDetail.url {
                HStack {
                    Label(Text("URL"), systemImage: "safari")
                    Spacer()
                    Link(url.absoluteString, destination: url)
                }
                .accessibilityElement(children: .combine)
            }

            if let userCreationDate = userDetail.userCreationDate {
                HStack {
                    Label(Text("Joined"), systemImage: "calendar")
                    Spacer()
                    Text(userCreationDate.formatted(date: .numeric, time: .standard))
                    .accessibilityLabel(Text(userCreationDate.formatted(date: .complete, time: .standard)))
                }
                .accessibilityElement(children: .combine)
            }

            if userDetail.isProtected {
                Label(Text("Protected"), systemImage: "lock")
            }

            if userDetail.isVerified {
                Label(Text("Verified"), systemImage: "checkmark.seal")
            }
        }
    }
}

//#if DEBUG
//struct UserDetailProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserDetailProfileView(userDetail: nil)
//    }
//}
//#endif
