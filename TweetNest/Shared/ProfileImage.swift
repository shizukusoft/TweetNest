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
            DataAsset(url: userDetail.profileImageURL) { data in
                if let image = Image(data: data) {
                    image
                        .resizable()
                } else {
                    Color.gray
                }
            }
        }
    }

    var body: some View {
        Group {
            if let userDetail = userDetail {
                Content(userDetail: userDetail)
            } else {
                Color.gray
            }
        }
        .clipShape(Circle())
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
