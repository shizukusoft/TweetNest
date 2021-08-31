//
//  withExtendedBackgroundExecution.swift
//  withExtendedBackgroundExecution
//
//  Created by Jaehong Kang on 2021/08/30.
//

import Foundation

public func withExtendedBackgroundExecution<T>(identifier: String = #function, body: () async throws -> T) async rethrows -> T {
    #if !os(macOS)
    let taskSemaphore = DispatchSemaphore(value: 0)
    let cancellationSemaphore = DispatchSemaphore(value: 0)
    defer {
        taskSemaphore.signal()
        cancellationSemaphore.signal()
    }

    withUnsafeCurrentTask { task in
        ProcessInfo.processInfo.performExpiringActivity(withReason: identifier) { expired in
            if expired {
                task?.cancel()
                cancellationSemaphore.wait()
            } else {
                taskSemaphore.wait()
            }
        }
    }
    #else
    let token = ProcessInfo.processInfo.beginActivity(options: .idleSystemSleepDisabled, reason: identifier)
    defer {
        ProcessInfo.processInfo.endActivity(token)
    }
    #endif
    
    return try await body()
}
