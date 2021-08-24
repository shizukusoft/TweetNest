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
                    .layoutPriority(1)
                    .lineLimit(1)
                    .allowsTightening(true)
                    Spacer()
                    if let locationQueryURL = locationQueryURL {
                        Link(location, destination: locationQueryURL)
                    }
                    else {
                        Text(location)
                    }
                }
                .accessibilityElement()
                .accessibilityLabel(Text("Location"))
                .accessibilityValue(Text(location))
                .accessibilityAddTraits(locationQueryURL != nil ? .isButton : [])
            }

            if let url = userDetail.url {
                HStack {
                    Label(Text("URL"), systemImage: "safari")
                    .layoutPriority(1)
                    .lineLimit(1)
                    .allowsTightening(true)
                    Spacer()
                    Link(url.absoluteString, destination: url)
                }
                .accessibilityElement()
                .accessibilityLabel(Text("URL"))
                .accessibilityValue(Text(url.absoluteString))
                .accessibilityAddTraits(.isButton)
            }

            if let userCreationDate = userDetail.userCreationDate {
                HStack {
                    Label(Text("Joined"), systemImage: "calendar")
                    .layoutPriority(1)
                    .lineLimit(1)
                    .allowsTightening(true)
                    Spacer()
                    Text(userCreationDate.formatted(date: .numeric, time: .standard))
                    .multilineTextAlignment(.trailing)
                }
                .accessibilityElement()
                .accessibilityLabel(Text("Joined"))
                .accessibilityValue(Text(userCreationDate.formatted(date: .long, time: .standard)))
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
