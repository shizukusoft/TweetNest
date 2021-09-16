//
//  TweetNestLaunchTests.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/09/16.
//

import XCTest

class TweetNestLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-com.tweetnest.TweetNest.Preview")

        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        addUIInterruptionMonitor(withDescription: "System Alerts") { (alert) -> Bool in
            let allowButton = alert.buttons["Allow"]

            if allowButton.exists {
                allowButton.tap()
                return true
            }

            return false
        }

        app.staticTexts["TweetNest"].tap() // For activate UIInterruptionMonitor

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
