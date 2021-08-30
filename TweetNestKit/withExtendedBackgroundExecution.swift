//
//  withExtendedBackgroundExecution.swift
//  withExtendedBackgroundExecution
//
//  Created by Jaehong Kang on 2021/08/30.
//

import Foundation
import UIKit

public func withExtendedBackgroundExecution<T>(identifier: String = #function, body: () async throws -> T) async rethrows -> T {
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
    
    return try await withTaskCancellationHandler { () -> T in
        defer {
            semaphore.signal()
        }
        
        return try await body()
    } onCancel: {
        semaphore.signal()
    }
}
