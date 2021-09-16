//
//  TweetNestScreenTests.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/09/16.
//

import XCTest

class TweetNestScreenTests: XCTestCase {
    let app = XCUIApplication()

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUp() async throws {
        continueAfterFailure = false

        app.launchArguments = ["-com.tweetnest.TweetNest.Preview"]
    }

    func testLaunch() throws {
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

        if app.navigationBars.buttons["BackButton"].exists {
            app.navigationBars.buttons["BackButton"].tap()
        }

        _ = app.navigationBars["TweetNest"].staticTexts["TweetNest"].waitForExistence(timeout: 5)

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testAccount() throws {
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

        if app.navigationBars.buttons["BackButton"].exists {
            app.navigationBars.buttons["BackButton"].tap()
        }

        let tablesQuery = app.tables
        tablesQuery.buttons["@TweetNest_App's Account"].tap()

        _ = app.navigationBars["@TweetNest_App"].staticTexts["@TweetNest_App"].waitForExistence(timeout: 5)

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Account Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testFollowingsHistory() throws {
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

        if app.navigationBars.buttons["BackButton"].exists {
            app.navigationBars.buttons["BackButton"].tap()
        }

        let tablesQuery = app.tables
        tablesQuery.buttons["@TweetNest_App's Followings History"].tap()

        _ = app.staticTexts["@Apple"].waitForExistence(timeout: 5)

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Followings History Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testFollowersHistory() throws {
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

        if app.navigationBars.buttons["BackButton"].exists {
            app.navigationBars.buttons["BackButton"].tap()
        }

        let tablesQuery = app.tables
        tablesQuery.buttons["@TweetNest_App's Followers History"].tap()

        _ = app.staticTexts["@Apple"].waitForExistence(timeout: 5)

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Followers History Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
