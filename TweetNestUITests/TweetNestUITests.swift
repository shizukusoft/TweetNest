//
//  TweetNestUITests.swift
//  TweetNestUITests
//
//  Created by Jaehong Kang on 2022/08/09.
//

import XCTest

final class TweetNestUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            let app = UIApplication()
            app.isPreview = true

            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                app.launch()
            }

            let attachment = XCTAttachment(screenshot: app.screenshot())
            attachment.name = "Launch Screen"
            attachment.lifetime = .keepAlways
            add(attachment)
        }
    }
}
