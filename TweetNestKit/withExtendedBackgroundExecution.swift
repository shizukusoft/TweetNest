//
//  withExtendedBackgroundExecution.swift
//  withExtendedBackgroundExecution
//
//  Created by Jaehong Kang on 2021/08/30.
//

import Foundation
import UnifiedLogging

public func withExtendedBackgroundExecution<T>(identifier: String = #function, body: () async throws -> T) async rethrows -> T {
    #if !os(macOS)
    let logger = Logger(subsystem: Bundle.module.bundleIdentifier!, category: "process-activity")
    
    let taskSemaphore = DispatchSemaphore(value: 0)
    let cancellationSemaphore = DispatchSemaphore(value: 0)
    defer {
        taskSemaphore.signal()
        cancellationSemaphore.signal()
    }

    withUnsafeCurrentTask { task in
        ProcessInfo.processInfo.performExpiringActivity(withReason: identifier) { expired in
            if expired {
                logger.notice("\(identifier): Canceling process activity")
                task?.cancel()
                logger.notice("\(identifier): Waiting for process activity cancelled")
                cancellationSemaphore.wait()
                logger.notice("\(identifier): Process activity cancelled")
            } else {
                logger.notice("\(identifier): Waiting for process activity done")
                taskSemaphore.wait()
                logger.notice("\(identifier): Process activity done")
            }
        }
    }
    #else
    let token = ProcessInfo.processInfo.beginActivity(options: .idleSystemSleepDisabled, reason: identifier)
    defer {
        ProcessInfo.processInfo.endActivity(token)
    }
    #endif
    
    logger.notice("\(identifier): Starting process activity")
    return try await body()
}
