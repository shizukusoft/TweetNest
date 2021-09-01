//
//  BackgroundTasks.swift
//  BackgroundTasks
//
//  Created by Jaehong Kang on 2021/08/30.
//

import Foundation
import UnifiedLogging

@inlinable
public func withExtendedBackgroundExecution<T>(function: String = #function, fileID: String = #fileID, line: Int = #line, body: () async throws -> T) async rethrows -> T {
    try await withExtendedBackgroundExecution(identifier: "\(function) (\(fileID):\(line))", body: body)
}

public func withExtendedBackgroundExecution<T>(identifier: String, body: () async throws -> T) async rethrows -> T {
    #if !os(macOS)
    try await withTaskExpirationHandler { expirationHandler in
        let logger = Logger(subsystem: Bundle.module.bundleIdentifier!, category: "process-activity")
        
        let taskSemaphore = DispatchSemaphore(value: 0)
        defer {
            taskSemaphore.signal()
        }

        ProcessInfo.processInfo.performExpiringActivity(withReason: identifier) { expired in
            if expired {
                logger.notice("\(identifier): Canceling process activity")
                expirationHandler()
                logger.notice("\(identifier): Process activity cancelled")
            } else {
                taskSemaphore.wait()
            }
        }
        
        logger.notice("\(identifier): Starting process activity")
        defer {
            logger.notice("\(identifier): Process activity finished with cancelled: \(Task.isCancelled)")
        }

        return try await body()
    }
    #else
    let token = ProcessInfo.processInfo.beginActivity(options: .idleSystemSleepDisabled, reason: identifier)
    defer {
        ProcessInfo.processInfo.endActivity(token)
    }
    
    logger.notice("\(identifier): Starting process activity")
    defer {
        logger.notice("\(identifier): Process activity finished with cancelled: \(Task.isCancelled)")
    }

    return try await body()
    #endif
}

@inlinable
public func withTaskExpirationHandler<T>(body: (@escaping @Sendable () -> Void) async throws -> T) async rethrows -> T {
    let cancellationSemaphore = DispatchSemaphore(value: 0)
    defer {
        cancellationSemaphore.signal()
    }
    
    let cancel = withUnsafeCurrentTask { $0?.cancel }
    @Sendable func expirationHandler() {
        cancel?()
        cancellationSemaphore.wait()
    }
    
    return try await body(expirationHandler)
}
