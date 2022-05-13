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

        if app.navigationBars.buttons["BackButton"].exists {
            app.navigationBars.buttons["BackButton"].tap()
        }

        #if os(macOS)
        XCTAssertTrue(app.disclosureTriangles[Self.dispalyUserName].waitForExistence(timeout: 5))
        #else
        XCTAssertTrue(app.staticTexts[Self.dispalyUserName].waitForExistence(timeout: 5))
        #endif
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

        wait(for: [
            expectation(for: .init(format: "exists == 0"), evaluatedWith: app.scrollBars.element, handler: nil)
        ], timeout: 5.0)

        takeScreenshot(name: "Launch Screen")
    }

    func testAccount() throws {
        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        #if os(macOS)
        app.buttons["\(Self.dispalyUserName):Account"].click()

        XCTAssertTrue(app.tables.staticTexts[Self.dispalyUserName].waitForExistence(timeout: 5))
        #else
        app.buttons["\(Self.dispalyUserName):Account"].tap()

        XCTAssertTrue(app.navigationBars[Self.dispalyUserName].staticTexts[Self.dispalyUserName].waitForExistence(timeout: 5))

        wait(for: [
            expectation(for: .init(format: "exists == 0"), evaluatedWith: app.scrollBars.element, handler: nil)
        ], timeout: 5.0)
        #endif

        takeScreenshot(name: "Account Screen")
    }

    func testFollowingsHistory() throws {
        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        #if os(macOS)
        app.buttons["\(Self.dispalyUserName):FollowingsHistory"].click()

        app.tables.tableRows.buttons["Apple"].click()
        #else
        app.buttons["\(Self.dispalyUserName):FollowingsHistory"].tap()

        XCTAssertTrue(app.staticTexts["@Apple"].waitForExistence(timeout: 5))

        wait(for: [
            expectation(for: .init(format: "exists == 0"), evaluatedWith: app.scrollBars.element, handler: nil)
        ], timeout: 5.0)
        #endif

        takeScreenshot(name: "Followings History Screen")
    }

    #if !os(watchOS)
    func testBatchDeleteTweetsForm() throws {
        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        #if os(macOS)
        app.buttons["\(Self.dispalyUserName):Account"].click()

        XCTAssertTrue(app.tables.staticTexts[Self.dispalyUserName].waitForExistence(timeout: 5))

        app.toolbars.popUpButtons["Delete"].click()
        app.toolbars.menuItems["Delete Recent Tweets"].click()

        XCTAssertTrue(app.windows.firstMatch.sheets.firstMatch.waitForExistence(timeout: 5))
        #else
        app.buttons["\(Self.dispalyUserName):Account"].tap()

        XCTAssertTrue(app.navigationBars[Self.dispalyUserName].staticTexts[Self.dispalyUserName].waitForExistence(timeout: 5))

        if app.buttons["Delete"].exists {
            app.buttons["Delete"].tap()
            app.buttons["Delete Recent Tweets"].tap()
        } else if app.navigationBars[Self.dispalyUserName].buttons["More"].exists {
            app.navigationBars[Self.dispalyUserName].buttons["More"].tap()
            app.collectionViews.buttons.element(boundBy: 3).tap() // app.collectionViews/*@START_MENU_TOKEN@*/.buttons["Delete"]/*[[".cells.buttons[\"Delete\"]",".buttons[\"Delete\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            app.buttons["Delete Recent Tweets"].tap()
        } else {
            #if os(watchOS)
            scrollDown()
            #endif

            app.buttons["Delete Recent Tweets"].tap()
        }

        XCTAssertTrue(app.switches.firstMatch.waitForExistence(timeout: 5))

        wait(for: [
            expectation(for: .init(format: "exists == 0"), evaluatedWith: app.scrollBars.element, handler: nil)
        ], timeout: 5.0)
        #endif

        takeScreenshot(name: "Batch Delete Tweets Form Screen")
    }

    private func scrollDown() {
        let relativeTouchPoint = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 1.0))
        let relativeOffset = app.coordinate(withNormalizedOffset: CGVector(dx: 0.0, dy: -1.0))
        relativeTouchPoint.press(forDuration: 0, thenDragTo: relativeOffset)
    }
    #endif

    private func takeScreenshot(name: String) {
        let attachment = XCTAttachment(screenshot: app.windows.firstMatch.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
