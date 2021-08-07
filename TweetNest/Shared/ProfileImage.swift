//
//  ProfileImage.swift
//  ProfileImage
//
//  Created by Jaehong Kang on 2021/08/08.
//

import SwiftUI
import TweetNestKit

struct ProfileImage: View {
    var userData: UserData?

    struct Content: View {
        @ObservedObject var userData: UserData

        var body: some View {
            DataAsset(url: userData.profileImageURL) { data in
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
            if let userData = userData {
                Content(userData: userData)
            } else {
                Color.gray
            }
        }
        .clipShape(Circle())
    }
}

#if DEBUG
struct ProfileImage_Previews: PreviewProvider {
    static var previews: some View {
        ProfileImage(userData: nil)
    }
}
#endif
