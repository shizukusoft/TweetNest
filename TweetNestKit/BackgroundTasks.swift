//
//  BackgroundTasks.swift
//  BackgroundTasks
//
//  Created by Jaehong Kang on 2021/08/30.
//

import Foundation
import UnifiedLogging

@inlinable
public func withExtendedBackgroundExecution<T>(function: String = #function, fileID: String = #fileID, line: Int = #line, expirationHandler: (() -> Void)? = nil, body: () throws -> T) rethrows -> T {
    try withExtendedBackgroundExecution(identifier: "\(function) (\(fileID):\(line))", expirationHandler: expirationHandler, body: body)
}

public func withExtendedBackgroundExecution<T>(identifier: String, expirationHandler: (() -> Void)? = nil, body: () throws -> T) rethrows -> T {
    let logger = Logger(subsystem: Bundle.tweetNestKit.bundleIdentifier!, category: "extended-background-execution")

    #if os(macOS)
    let token = ProcessInfo.processInfo.beginActivity(options: [.idleSystemSleepDisabled, .suddenTerminationDisabled, .automaticTerminationDisabled], reason: identifier)
    defer {
        ProcessInfo.processInfo.endActivity(token)
    }
    #else
    let dispatchGroup = DispatchGroup()
    dispatchGroup.enter()
    defer {
        dispatchGroup.leave()
    }

    ProcessInfo.processInfo.performExpiringActivity(withReason: identifier) { expired in
        if expired {
            logger.notice("\(identifier, privacy: .public): Expiring activity expired")
            expirationHandler?()
            logger.notice("\(identifier, privacy: .public): Expiring activity expirationHandler finished")
        } else {
            logger.info("\(identifier, privacy: .public): Start expiring activity")
            dispatchGroup.wait()
            logger.info("\(identifier, privacy: .public): Expiring activity finished")
        }
    }
    #endif

    logger.notice("\(identifier, privacy: .public): Start")
    defer {
        logger.notice("\(identifier, privacy: .public): Finished with cancelled: \(Task.isCancelled)")
    }

    return try body()
}

extension Task where Success == Never, Failure == Never {
    @TaskLocal fileprivate static var isInExtendedBackgroundExecution: Bool = false
}

@inlinable
public func withExtendedBackgroundExecution<T>(function: String = #function, fileID: String = #fileID, line: Int = #line, body: @escaping @Sendable () async throws -> T) async throws -> T {
    try await withExtendedBackgroundExecution(identifier: "\(function) (\(fileID):\(line))", body: body)
}

public func withExtendedBackgroundExecution<T>(identifier: String, body: @escaping @Sendable () async throws -> T) async throws -> T {
    guard Task.isInExtendedBackgroundExecution == false else {
        return try await body()
    }

    return try await withTaskExpirationHandler { expirationHandler in
        return try await handleExtendedBackgroundExecution(identifier: identifier, expirationHandler: expirationHandler, body: body)
    }
}

@inlinable
public func withExtendedBackgroundExecution<T>(function: String = #function, fileID: String = #fileID, line: Int = #line, body: @escaping @Sendable () async -> T) async -> T {
    await withExtendedBackgroundExecution(identifier: "\(function) (\(fileID):\(line))", body: body)
}

public func withExtendedBackgroundExecution<T>(identifier: String, body: @escaping @Sendable () async -> T) async -> T {
    guard Task.isInExtendedBackgroundExecution == false else {
        return await body()
    }

    return await withTaskExpirationHandler { expirationHandler in
        return await handleExtendedBackgroundExecution(identifier: identifier, expirationHandler: expirationHandler, body: body)
    }
}

private func handleExtendedBackgroundExecution<T>(identifier: String, expirationHandler: @escaping @Sendable () -> Void, body: @escaping @Sendable () async throws -> T) async rethrows -> T {
    try await Task.$isInExtendedBackgroundExecution.withValue(true) {
        let logger = Logger(subsystem: Bundle.tweetNestKit.bundleIdentifier!, category: "extended-background-execution")

        #if os(macOS)
        let token = ProcessInfo.processInfo.beginActivity(options: [.idleSystemSleepDisabled, .suddenTerminationDisabled, .automaticTerminationDisabled], reason: identifier)
        defer {
            ProcessInfo.processInfo.endActivity(token)
        }
        #else
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        defer {
            dispatchGroup.leave()
        }

        ProcessInfo.processInfo.performExpiringActivity(withReason: identifier) { expired in
            if expired {
                logger.notice("\(identifier, privacy: .public): Expiring activity expired")
                expirationHandler()
                logger.notice("\(identifier, privacy: .public): Expiring activity expirationHandler finished")
            } else {
                logger.info("\(identifier, privacy: .public): Start expiring activity")
                dispatchGroup.wait()
                logger.info("\(identifier, privacy: .public): Expiring activity finished")
            }
        }
        #endif

        logger.notice("\(identifier, privacy: .public): Start")
        defer {
            logger.notice("\(identifier, privacy: .public): Finished with cancelled: \(Task.isCancelled)")
        }

        return try await body()
    }
}
