//
//  UIApplication.swift
//  TweetNestUITests
//
//  Created by 강재홍 on 2022/08/19.
//

import XCTest

final class UIApplication: XCUIApplication {
    var isPreview: Bool {
        get {
            launchArguments.contains("-com.tweetnest.TweetNest.Preview")
        }
        set {
            if newValue {
                guard launchArguments.contains("-com.tweetnest.TweetNest.Preview") else {
                    return
                }

                launchArguments.append("-com.tweetnest.TweetNest.Preview")
            } else {
                launchArguments.removeAll(where: { $0 == "-com.tweetnest.TweetNest.Preview" })
            }
        }
    }
}
