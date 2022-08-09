//
//  Session+Support.swift
//  TweetNestKit
//
//  Created by 강재홍 on 2022/04/20.
//

import Foundation
import CloudKit
import UnifiedLogging

extension Session {
    static let applicationGroupIdentifier = "group.\(Bundle.tweetNestKit.bundleIdentifier!)"

    static let isSandbox: Bool = {
        #if DEBUG
        let isRunningOnXCTest = ProcessInfo.processInfo.environment.keys
            .contains { $0.range(of: "XC", options: .caseInsensitive)?.lowerBound == $0.startIndex }

        if isRunningOnXCTest {
            return true
        } else {
            return CKContainer.default().value(forKeyPath: "containerID.environment") as? CLongLong == 2
        }
        #else
        return CKContainer.default().value(forKeyPath: "containerID.environment") as? CLongLong == 2
        #endif
    }()

    static var containerURL: URL {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Session.applicationGroupIdentifier)!
    }

    static var containerLibraryURL: URL {
        containerURL.appendingPathComponent("Library")
    }

    static var containerCacheURL: URL {
        containerLibraryURL
            .appendingPathComponent("Caches")
            .appendingPathComponent(Bundle.tweetNestKit.bundleIdentifier!)
    }

    static var containerApplicationSupportURL: URL {
        let containerApplicationSupportURL = containerLibraryURL
            .appendingPathComponent("Application Support")
            .appendingPathComponent(Bundle.tweetNestKit.bundleIdentifier!)

        if isSandbox {
            return containerApplicationSupportURL.appendingPathExtension("sandbox")
        } else {
            // Migration START
            let oldURL = Session.containerURL
                .appendingPathComponent("Application Support")
                .appendingPathComponent(Bundle.tweetNestKit.name!)
            let newURL = containerApplicationSupportURL
            if FileManager.default.fileExists(atPath: oldURL.path) {
                do {
                    try FileManager.default.createDirectory(
                        at: newURL.deletingLastPathComponent(),
                        withIntermediateDirectories: true,
                        attributes: nil
                    )
                    try FileManager.default.moveItem(at: oldURL, to: newURL)
                    try FileManager.default.removeItem(at: oldURL.deletingLastPathComponent())
                } catch {
                    Logger(label: Bundle.tweetNestKit.bundleIdentifier!, category: String(reflecting: Self.self))
                        .error("\(error as NSError, privacy: .public)")
                }
            }
            // Migration END

            return containerApplicationSupportURL
        }
    }
}
