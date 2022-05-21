//
//  ProfileImage.swift
//  ProfileImage
//
//  Created by Jaehong Kang on 2021/08/08.
//

import SwiftUI
import TweetNestKit

struct ProfileImage: View {
    let profileImageURL: URL?
    let isExportable: Bool

    var body: some View {
        UserDataAssetImage(url: profileImageURL, isExportable: isExportable)
            .clipShape(Circle())
            .accessibilityElement(children: .ignore)
            .accessibilityHidden(true)
    }

    init(profileImageURL: URL?, isExportable: Bool = false) {
        self.profileImageURL = profileImageURL
        self.isExportable = isExportable
    }
}

#if DEBUG
struct ProfileImage_Previews: PreviewProvider {

    private static let url: URL =
        .init(string: "https://pbs.twimg.com/profile_images/1373878674903113729/JL3SGoch.png")!

    static var previews: some View {
        ZStack {
            Rectangle()
            .fill(.black)
            .ignoresSafeArea()
            ProfileImage(profileImageURL: url)
            .aspectRatio(contentMode: .fit)
        }
    }
}
#endif
