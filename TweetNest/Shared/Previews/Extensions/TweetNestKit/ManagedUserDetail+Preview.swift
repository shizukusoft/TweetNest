//
//  ManagedUserDetail+Preview.swift
//  TweetNest
//
//  Created by Mina Her on 2022/05/19.
//

#if DEBUG
import Foundation
import TweetNestKit

extension TweetNestKit.ManagedUserDetail {

    @inlinable
    static var preview: ManagedUserDetail {
        previews.first!
    }

    @inlinable
    static var previews: [ManagedUserDetail] {
        ManagedUser.preview.userDetails!
    }
}
#endif
