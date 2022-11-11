//
//  ProcessInfo.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2022/08/27.
//

import Foundation

extension ProcessInfo {
    var isPreview: Bool {
        #if DEBUG
        arguments.contains("-com.tweetnest.TweetNest.Preview") ||
            environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        #else
        return false
        #endif
    }
}
