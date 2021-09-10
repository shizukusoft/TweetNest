//
//  ProfileImage.swift
//  ProfileImage
//
//  Created by Jaehong Kang on 2021/08/08.
//

import SwiftUI
import TweetNestKit

struct ProfileImage: View {
    var userDetail: UserDetail?

    struct Content: View {
        @ObservedObject var userDetail: UserDetail

        var body: some View {
            DataAssetImage(url: userDetail.profileImageURL) { image in
                if let image = image {
                    image
                        .interpolation(.high)
                        .resizable()
                } else {
                    Color.gray
                }
            }
        }
    }
    
    @ViewBuilder private var profileImage: some View {
        if let userDetail = userDetail {
            Content(userDetail: userDetail)
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
        ProfileImage(userDetail: nil)
    }
}
#endif
