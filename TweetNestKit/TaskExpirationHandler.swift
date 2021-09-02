//
//  TaskExpirationHandler.swift
//  TaskExpirationHandler
//
//  Created by Jaehong Kang on 2021/09/02.
//

import Foundation

public func withTaskExpirationHandler<T>(body: @escaping (@escaping @Sendable () -> Void) async -> T) async -> T {
    return await TaskExpirationHandler<T, Never>().run(body: body)
}

public func withTaskExpirationHandler<T>(body: @escaping (@escaping @Sendable () -> Void) async throws -> T) async throws -> T {
    return try await TaskExpirationHandler<T, Error>().run(body: body)
}

private actor TaskExpirationHandler<Success, Failure> where Failure: Error {
    private let cancellationSemaphore = DispatchSemaphore(value: 0)
    private var task: Task<Success, Failure>?

    func updateTask(_ task: Task<Success, Failure>?) {
        self.task = task
    }
}

extension TaskExpirationHandler {
    @Sendable
    nonisolated func cancel() {
        Task.detached(priority: .high) {
            await self.task?.cancel()
        }
        cancellationSemaphore.wait()
    }
}

extension TaskExpirationHandler where Failure == Error {
    @Sendable
    nonisolated func run(body: @escaping (@escaping @Sendable () -> Void) async throws -> Success) async throws -> Success {
        let task = Task<Success, Error> {
            defer {
                cancellationSemaphore.signal()
            }

            return try await body(self.cancel)
        }

        await updateTask(task)

        return try await withTaskCancellationHandler {
            return try await task.value
        } onCancel: {
            cancel()
        }
    }
}

extension TaskExpirationHandler where Failure == Never {
    @Sendable
    nonisolated func run(body: @escaping (@escaping @Sendable () -> Void) async -> Success) async -> Success {
        let task = Task<Success, Never> {
            defer {
                cancellationSemaphore.signal()
            }

            return await body(self.cancel)
        }

        await updateTask(task)

        return await withTaskCancellationHandler {
            return await task.value
        } onCancel: {
            cancel()
        }
    }
}
