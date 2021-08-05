//
//  SecureUnarchiveFromDataTransformer.swift
//  TweetNestKit
//
//  Created by Jaehong Kang on 2021/08/05.
//

import Foundation

class SecureUnarchiveFromDataTransformer: NSSecureUnarchiveFromDataTransformer{
    override class var allowedTopLevelClasses: [AnyClass] {
        return super.allowedTopLevelClasses + [NSAttributedString.self]
    }
}
