//
//  UserView.swift
//  UserView
//
//  Created by Jaehong Kang on 2021/08/02.
//

import SwiftUI
import TweetNestKit

struct UserView: View {
    let user: User?
    
    var body: some View {
        Group {
            if let user = user {
                UserContentView(user: user)
            } else {
                EmptyView()
            }
        }
    }
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView(user: Account.preview.user!)
    }
}
