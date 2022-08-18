//
//  SessionError.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/02/27.
//

import Foundation

enum SessionError: Swift.Error {
    case unknown
    case noCloudKitRecord
    case noAPIKey
    case noAPIKeySecret
    case invalidServerResponse(URLResponse)
}
