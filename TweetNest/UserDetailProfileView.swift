//
//  UserDetailProfileView.swift
//  UserDetailProfileView
//
//  Created by Jaehong Kang on 2021/08/03.
//

import SwiftUI
import TweetNestKit

struct UserDetailProfileView: View {
    @ObservedObject var userDetail: ManagedUserDetail

    @Environment(\.openURL) private var openURL

    var body: some View {
        Group {
            #if os(iOS) || os(macOS)
            if let profileHeaderImageURL = userDetail.profileHeaderImageURL {
                UserDataAssetImage(url: profileHeaderImageURL, isExportable: true)
                    .aspectRatio(3, contentMode: .fill)
                    #if os(iOS)
                    .listRowSeparator(.hidden)
                    #endif
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
            #endif

            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 8) {
                    ProfileImage(profileImageURL: userDetail.profileImageURL, isExportable: true)
                        #if !os(watchOS)
                        .frame(width: 48, height: 48)
                        #else
                        .frame(width: 36, height: 36)
                        #endif

                    VStack(alignment: .leading, spacing: 4) {
                        Text(verbatim: userDetail.name ?? userDetail.userID?.displayUserID ?? "")
                            #if os(macOS) || os(iOS)
                            .textSelection(.enabled)
                            #endif

                        if let displayUsername = userDetail.displayUsername {
                            Text(verbatim: displayUsername)
                                #if os(macOS) || os(iOS)
                                .textSelection(.enabled)
                                #endif
                                .foregroundColor(.secondary)
                        }
                    }
                }

                if
                    let userAttributedDescription = userDetail.userAttributedDescription.flatMap(AttributedString.init),
                    userAttributedDescription.startIndex != userAttributedDescription.endIndex
                {
                    Text(userAttributedDescription)
                        #if os(macOS) || os(iOS)
                        .textSelection(.enabled)
                        #endif
                        .layoutPriority(1)
                }
            }
            .padding([.top, .bottom], 8)

            if let location = userDetail.location, !location.isEmpty {
                let locationQueryURL = location
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                .flatMap({ URL(string: "http://maps.apple.com/?q=\($0)") })

                Label {
                    TweetNestStack {
                        Text("Location")
                            .layoutPriority(1)
                            .lineLimit(1)
                        #if !os(watchOS)
                        Spacer()
                        #endif
                        Group {
                            if let locationQueryURL = locationQueryURL {
                                Link(location, destination: locationQueryURL)
                            } else {
                                Text(location)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .lineLimit(1)
                        .allowsTightening(true)
                        #if os(macOS)
                        .textSelection(.enabled)
                        #endif
                    }
                } icon: {
                    Image(systemName: "location")
                }
                #if os(iOS)
                .contextMenu {
                    Button(
                        action: {
                            Pasteboard.general.string = location
                        },
                        label: {
                            Label("Copy", systemImage: "doc.on.doc")
                        })
                }
                #endif
                .accessibilityElement()
                .accessibilityLabel(Text("Location"))
                .accessibilityValue(Text(location))
                .accessibilityAddTraits(locationQueryURL != nil ? .isButton : [])
            }

            if let url = userDetail.url {
                Label {
                    TweetNestStack {
                        Text("URL")
                            .layoutPriority(1)
                            .lineLimit(1)
                        #if !os(watchOS)
                        Spacer()
                        #endif
                        Link(url.simplifiedString, destination: url)
                            .lineLimit(1)
                            .allowsTightening(true)
                            #if os(macOS)
                            .textSelection(.enabled)
                            #endif
                    }
                } icon: {
                    Image(systemName: "safari")
                }
                #if os(iOS)
                .contextMenu {
                    Button(
                        action: {
                            Pasteboard.general.url = url
                        },
                        label: {
                            Label("Copy", systemImage: "doc.on.doc")
                        })
                }
                #endif
                .accessibilityElement()
                .accessibilityLabel(Text("URL"))
                .accessibilityValue(Text(url.absoluteString))
                .accessibilityAddTraits(.isButton)
            }

            if let userCreationDate = userDetail.userCreationDate {
                let dateString = userCreationDate.twnk_formatted(shouldCompact: false)
                Label {
                    TweetNestStack {
                        Text("Joined")
                            .layoutPriority(1)
                            .lineLimit(1)
                        #if !os(watchOS)
                        Spacer()
                        #endif
                        Group {
                            DateText(date: userCreationDate)
                        }
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .allowsTightening(true)
                        #if os(macOS)
                        .textSelection(.enabled)
                        #endif
                    }
                } icon: {
                    Image(systemName: "calendar")
                }
                #if os(iOS)
                .contextMenu {
                    Button(
                        action: {
                            Pasteboard.general.string = dateString
                        },
                        label: {
                            Label("Copy", systemImage: "doc.on.doc")
                        })
                }
                #endif
                .accessibilityElement()
                .accessibilityLabel(Text("Joined"))
                .accessibilityValue(dateString)
            }

            if userDetail.isProtected {
                Label("Protected", systemImage: "lock")
            }

            if userDetail.isVerified {
                Label("Verified", systemImage: "checkmark.seal")
            }
        }
    }
}

// #if DEBUG
// struct UserDetailProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserDetailProfileView(userDetail: nil)
//    }
// }
// #endif
