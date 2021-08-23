//
//  TwitterArchiveManager.swift
//  TwitterArchiveManager
//
//  Created by Jaehong Kang on 2021/08/18.
//

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
                var error: NSError? = nil
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
            let tweetJSData = try await data(atPath: "data/tweet.js")
            
            return try autoreleasepool {
                guard let tweetJS = String(data: tweetJSData, encoding: .utf8) else {
                    throw TwitterArchiveError.dataCorrupted
                }

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
}
