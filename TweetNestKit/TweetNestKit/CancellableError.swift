//
//  CancellableError.swift
//  TweetNestKit
//
//  Created by Jaehong Kang on 2022/11/05.
//

import Foundation

public protocol CancellableError: Error {
    var isCancelled: Bool { get }
}

extension CancellationError: CancellableError {
    public var isCancelled: Bool {
        return true
    }
}

extension URLError: CancellableError {
    public var isCancelled: Bool {
        switch self {
        case URLError.cancelled:
            return true
        default:
            return false
        }
    }
}
