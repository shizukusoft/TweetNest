//
//  withExtendedBackgroundExecution.swift
//  withExtendedBackgroundExecution
//
//  Created by Jaehong Kang on 2021/08/30.
//

import Foundation
import UIKit

public func withExtendedBackgroundExecution<T>(identifier: String = #function, body: () async throws -> T) async rethrows -> T {
    #if !os(macOS)
    let semaphore = DispatchSemaphore(value: 0)
    defer {
        semaphore.signal()
    }
    
    withUnsafeCurrentTask { task in
        ProcessInfo.processInfo.performExpiringActivity(withReason: identifier) { expired in
            if expired {
                task?.cancel()
            } else {
                semaphore.wait()
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
