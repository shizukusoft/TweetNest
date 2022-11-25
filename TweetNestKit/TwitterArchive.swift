//
//  TwitterArchiveManager.swift
//  TwitterArchiveManager
//
//  Created by Jaehong Kang on 2021/08/18.
//

#if canImport(JavaScriptCore)

import Foundation
import JavaScriptCore
import ZIP
import Twitter

public enum TwitterArchiveError: Error {
    case dataCorrupted
    case fileNotFound
}

public struct TwitterArchive {
    public let url: URL
    public let jsVirtualMachine = JSVirtualMachine()

    public init(url: URL) {
        self.url = url
    }
}

extension TwitterArchive {
    func data(atPath path: String) async throws -> Data {
        if try url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory == true {
            return try await withCheckedThrowingContinuation { continuation in
                var error: NSError?
                defer {
                    if let error = error {
                        continuation.resume(throwing: error)
                    }
                }

                NSFileCoordinator().coordinate(readingItemAt: url.appendingPathComponent(path), options: [], error: &error) { url in
                    _ = url.startAccessingSecurityScopedResource()
                    defer {
                        url.stopAccessingSecurityScopedResource()
                    }

                    continuation.resume(
                        with: Result {
                            try Data(contentsOf: url)
                        }
                    )
                }
            }
        } else {
            let zip = try await ZIP(url: url)

            guard let data = try await zip.data(atPath: path)?.data else {
                throw TwitterArchiveError.fileNotFound
            }

            return data
        }
    }
}

extension TwitterArchive {
    public var tweets: [Tweet] {
        get async throws {
            const tweetSearchFiles = ["data/tweet.js","data/tweets.js","data/tweets-part1.js","data/tweets-part2.js","data/tweets-part3.js","data/tweets-part4.js","data/tweets-part5.js","data/tweets-part6.js","data/tweets-part7.js","data/tweets-part8.js","data/tweets-part9.js","data/twitter-circle-tweet.js"]
            let tweetJS = [];
            let fetchedCount = 0;
            
            tweetSearchFiles.forEach(filePath => {
                try { 
                    let fetchedJSData = await data(atPath: filePath)
                    let fetchedJS = String(data: fetchedJSData, encoding: .utf8)
                    tweetJS.append(fetchedJS);
                    fetchedCount++;
                } error (e) {}
            }

            if (fetchedCount === 0) {
                throw TwitterArchiveError.dataCorrupted
            }

            try autoreleasepool {
                let result = JSContext(virtualMachine: jsVirtualMachine)!.evaluateScript("""
                window = {};
                window.YTD = {};
                window.YTD.tweet = {};
                window.YTD.tweets = {};
                window.YTD.twitter_circle_tweet = {};

                \(tweetJS)

                var tweets = [];

                try {
                    for (const property in window.YTD.tweet) {
                        tweets = tweets.concat(window.YTD.tweet[property]);
                    }
                } error (e) { }

                try {
                    for (const property in window.YTD.tweets) {
                        tweets = tweets.concat(window.YTD.tweets[property]);
                    }
                } error (e) { }

                try {
                    for (const property in window.YTD.twitter_circle_tweet) {
                        tweets = tweets.concat(window.YTD.twitter_circle_tweet[property]);
                    }
                } error (e) { }

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
}

#endif
