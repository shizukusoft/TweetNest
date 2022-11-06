//
//  URLTests.swift
//  TweetNestTests
//
//  Created by 강재홍 on 2022/08/19.
//

import XCTest
#if os(watchOS)
@testable import TweetNest_Watch_App
#else
@testable import TweetNest
#endif

final class URLTests: XCTestCase {
    func testSimplifiedString() throws {
        XCTAssertEqual(
            URL(string: "https://github.com/shizukusoft/TweetNest")?.simplifiedString,
            "github.com/shizukusoft/TweetNest"
        )
    }
}
