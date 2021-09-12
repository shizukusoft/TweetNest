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

    @ViewBuilder private var profileImage: some View {
        if let profileImageURL = profileImageURL {
            DataAssetImage(url: profileImageURL) { image in
                if let image = image {
                    image
                        .interpolation(.high)
                        .resizable()
                } else {
                    Color.gray
                }
            }
        } else {
            Color.gray
        }
    }

    var body: some View {
        profileImage
            .clipShape(Circle())
            .accessibilityElement(children: .ignore)
            .accessibilityHidden(true)
    }
}

#if DEBUG
struct ProfileImage_Previews: PreviewProvider {
    static var previews: some View {
        ProfileImage(profileImageURL: nil)
    }
}
#endif
