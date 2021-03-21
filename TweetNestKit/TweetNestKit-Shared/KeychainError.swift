//
//  KeychainError.swift
//  TweetNestKit
//
//  Created by Jaehong Kang on 2021/02/24.
//

import Foundation

enum KeychainError: Swift.Error {
    case unhandledError(status: OSStatus)
    case noPassword
    case unexpectedPasswordData
}
