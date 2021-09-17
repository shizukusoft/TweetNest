//
//  TweetNestScreenTests.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/09/16.
//

import XCTest

class TweetNestScreenTests: XCTestCase {
    static let dispalyUserName = "@TweetNest_App"

    let app = XCUIApplication()

    private var systemAlertsUIInterruptionMonitorToken: NSObjectProtocol?

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false

        app.launchArguments = ["-com.tweetnest.TweetNest.Preview"]

        self.systemAlertsUIInterruptionMonitorToken = addUIInterruptionMonitor(withDescription: "System Alerts") { (alert) -> Bool in
            let allowButton = alert.buttons["Allow"]

            if allowButton.exists {
                allowButton.tap()
                return true
            }

            return false
        }

        app.launch()

        if app.navigationBars.buttons["BackButton"].waitForExistence(timeout: 1) {
            app.navigationBars.buttons["BackButton"].tap()
        }
    }

    override func tearDownWithError() throws {
        app.terminate()

        if let systemAlertsUIInterruptionMonitorToken = self.systemAlertsUIInterruptionMonitorToken {
            removeUIInterruptionMonitor(systemAlertsUIInterruptionMonitorToken)
        }
    }

    func testLaunch() throws {
        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        _ = app.staticTexts[Self.dispalyUserName].waitForExistence(timeout: 5)

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testAccount() throws {
        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        app.buttons["\(Self.dispalyUserName)'s Account"].tap()

        _ = app.navigationBars[Self.dispalyUserName].staticTexts[Self.dispalyUserName].waitForExistence(timeout: 5)

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Account Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testFollowingsHistory() throws {
        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        app.buttons["\(Self.dispalyUserName)'s Followings History"].tap()

        _ = app.staticTexts["@Apple"].waitForExistence(timeout: 5)

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Followings History Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testFollowersHistory() throws {
        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        app.buttons["\(Self.dispalyUserName)'s Followers History"].tap()

        _ = app.staticTexts["@Apple"].waitForExistence(timeout: 5)

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Followers History Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
