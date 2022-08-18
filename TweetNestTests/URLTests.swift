//
//  URLTests.swift
//  TweetNestTests
//
//  Created by 강재홍 on 2022/08/19.
//

import XCTest
@testable import TweetNest

final class URLTests: XCTestCase {
    func testSimplifiedString() throws {
        XCTAssertEqual(
            URL(string: "https://github.com/shizukusoft/TweetNest")?.simplifiedString,
            "github.com/shizukusoft/TweetNest"
        )
    }
}
