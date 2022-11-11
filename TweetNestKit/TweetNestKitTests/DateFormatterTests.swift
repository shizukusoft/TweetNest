//
//  DateFormatterTests.swift
//  TweetNestKitTests
//
//  Created by Jaehong Kang on 2022/08/17.
//

import XCTest
@testable import TweetNestKit

final class DateFormatterTests: XCTestCase {
    func testDateFromString() throws {
        let dateFormatter = DateFormatter.http

        let date1 = dateFormatter.date(from: "Tue, 15 Nov 1994 12:45:26 GMT")
        XCTAssertNotNil(date1)

        let date2 = dateFormatter.date(from: "Wed, 21 Oct 2015 07:28:00 GMT")
        XCTAssertNotNil(date2)
    }

    func testStringFromDate() throws {
        let dateFormatter = DateFormatter.http

        let date1 = Date(timeIntervalSinceReferenceDate: -193403674.0)
        XCTAssertEqual(
            dateFormatter.string(from: date1),
            "Tue, 15 Nov 1994 12:45:26 GMT"
        )

        let date2 = Date(timeIntervalSinceReferenceDate: 467105280.0)
        XCTAssertEqual(
            dateFormatter.string(from: date2),
            "Wed, 21 Oct 2015 07:28:00 GMT"
        )
    }
}
