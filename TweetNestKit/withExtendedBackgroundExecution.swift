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
    
    withUnsafeCurrentTask { task in
        ProcessInfo.processInfo.performExpiringActivity(withReason: identifier) { expired in
            if expired {
                task?.cancel()
            } else {
                semaphore.wait()
            }
        }
    }
    
    defer {
        semaphore.signal()
    }
    #else
    let token = ProcessInfo.processInfo.beginActivity(options: .idleSystemSleepDisabled, reason: identifier)
    defer {
        ProcessInfo.processInfo.endActivity(token)
    }
    #endif
    
    return try await body()
}
