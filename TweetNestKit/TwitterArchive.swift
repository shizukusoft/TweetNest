//
//  TwitterArchiveManager.swift
//  TwitterArchiveManager
//
//  Created by Jaehong Kang on 2021/08/18.
//

import Foundation
import JavaScriptCore
import Twitter

public enum TwitterArchiveError: Error {
    case dataCorrupted
}

public struct TwitterArchive {
    public let url: URL
    public let jsVirtualMachine = JSVirtualMachine()
    
    public init(url: URL) {
        self.url = url
    }
}

extension TwitterArchive {
    public var tweets: [Tweet] {
        get async throws {
            let tweetJSURL = url.appendingPathComponent("data/tweet.js")
            
            let tweetJS = try String(contentsOf: tweetJSURL)
            
            let result = JSContext(virtualMachine: jsVirtualMachine)!.evaluateScript("""
            window = {};
            window.YTD = {};
            window.YTD.tweet = {};
            
            \(tweetJS)
            
            var tweets = [];
            
            for (const property in window.YTD.tweet) {
                tweets = tweets.concat(window.YTD.tweet[property]);
            }
            
            tweets.map(x => x.tweet);
            """)
            
            guard let tweets = result?.toArray() else {
                throw TwitterArchiveError.dataCorrupted
            }
            
            let jsonData = try JSONSerialization.data(withJSONObject: tweets, options: [])

            return try JSONDecoder.twt_default.decode([Tweet].self, from: jsonData)
        }
    }
}
