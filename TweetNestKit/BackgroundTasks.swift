//
//  BackgroundTasks.swift
//  BackgroundTasks
//
//  Created by Jaehong Kang on 2021/08/30.
//

import Foundation
import UnifiedLogging

public func withExtendedBackgroundExecution<T>(identifier: String = #function, body: () async throws -> T) async rethrows -> T {
    #if !os(macOS)
    let logger = Logger(subsystem: Bundle.module.bundleIdentifier!, category: "process-activity")
    
    let taskSemaphore = DispatchSemaphore(value: 0)
    defer {
        taskSemaphore.signal()
        
        logger.notice("\(identifier): Process activity finished with cancelled: \(Task.isCancelled)")
    }
    
    return try await withTaskExpirationHandler { expirationHandler in
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
        return try await body()
    }
    #else
    let token = ProcessInfo.processInfo.beginActivity(options: .idleSystemSleepDisabled, reason: identifier)
    defer {
        ProcessInfo.processInfo.endActivity(token)
    }
    
    logger.notice("\(identifier): Starting process activity")
    return try await body()
    #endif
}

public func withTaskExpirationHandler<T>(body: (@escaping () -> Void) async throws -> T) async rethrows -> T {
    let cancellationSemaphore = DispatchSemaphore(value: 0)
    defer {
        cancellationSemaphore.signal()
    }
    
    let expirationHandler: () -> Void = withUnsafeCurrentTask { unsafeCurrentTask in
        {
            unsafeCurrentTask?.cancel()
            cancellationSemaphore.wait()
        }
    }
    
    return try await body(expirationHandler)
}
