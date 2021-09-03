//
//  BackgroundTasks.swift
//  BackgroundTasks
//
//  Created by Jaehong Kang on 2021/08/30.
//

import Foundation
import UnifiedLogging

@inlinable
public func withExtendedBackgroundExecution<T>(function: String = #function, fileID: String = #fileID, line: Int = #line, expirationHandler: (() -> ())? = nil, body: () throws -> T) rethrows -> T {
    try withExtendedBackgroundExecution(identifier: "\(function) (\(fileID):\(line))", expirationHandler: expirationHandler, body: body)
}

public func withExtendedBackgroundExecution<T>(identifier: String, expirationHandler: (() -> ())? = nil, body: () throws -> T) rethrows -> T {
    let logger = Logger(subsystem: Bundle.module.bundleIdentifier!, category: "process-activity")

    #if os(macOS)
    let token = ProcessInfo.processInfo.beginActivity(options: .idleSystemSleepDisabled, reason: identifier)
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
            logger.notice("\(identifier, privacy: .public): Cancel process activity")
            expirationHandler?()
            logger.notice("\(identifier, privacy: .public): Cancelling Process activity finished")
        } else {
            logger.notice("\(identifier, privacy: .public): Wait process activity")
            dispatchGroup.wait()
            logger.notice("\(identifier, privacy: .public): Waiting process activity finished")
        }
    }
    #endif

    logger.notice("\(identifier, privacy: .public): Start process activity")
    defer {
        logger.notice("\(identifier, privacy: .public): Process activity finished with cancelled: \(Task.isCancelled)")
    }

    return try body()
}

@inlinable
public func withExtendedBackgroundExecution<T>(function: String = #function, fileID: String = #fileID, line: Int = #line, body: @escaping () async throws -> T) async throws -> T {
    try await withExtendedBackgroundExecution(identifier: "\(function) (\(fileID):\(line))", body: body)
}

public func withExtendedBackgroundExecution<T>(identifier: String, body: @escaping () async throws -> T) async throws -> T {
    try await withTaskExpirationHandler { expirationHandler in
        return try await handleExtendedBackgroundExecution(identifier: identifier, expirationHandler: expirationHandler, body: body)
    }
}

@inlinable
public func withExtendedBackgroundExecution<T>(function: String = #function, fileID: String = #fileID, line: Int = #line, body: @escaping () async -> T) async -> T {
    await withExtendedBackgroundExecution(identifier: "\(function) (\(fileID):\(line))", body: body)
}

public func withExtendedBackgroundExecution<T>(identifier: String, body: @escaping () async -> T) async -> T {
    await withTaskExpirationHandler { expirationHandler in
        return await handleExtendedBackgroundExecution(identifier: identifier, expirationHandler: expirationHandler, body: body)
    }
}

private func handleExtendedBackgroundExecution<T>(identifier: String, expirationHandler: @escaping @Sendable () -> Void, body: @escaping () async throws -> T) async rethrows -> T {
    let logger = Logger(subsystem: Bundle.module.bundleIdentifier!, category: "process-activity")

    #if os(macOS)
    let token = ProcessInfo.processInfo.beginActivity(options: .idleSystemSleepDisabled, reason: identifier)
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
            logger.notice("\(identifier, privacy: .public): Cancel process activity")
            expirationHandler()
            logger.notice("\(identifier, privacy: .public): Cancelling Process activity finished")
        } else {
            logger.notice("\(identifier, privacy: .public): Wait process activity")
            dispatchGroup.wait()
            logger.notice("\(identifier, privacy: .public): Waiting process activity finished")
        }
    }
    #endif

    logger.notice("\(identifier, privacy: .public): Start process activity")
    defer {
        logger.notice("\(identifier, privacy: .public): Process activity finished with cancelled: \(Task.isCancelled)")
    }

    return try await body()
}
