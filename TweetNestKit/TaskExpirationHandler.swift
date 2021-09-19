//
//  TaskExpirationHandler.swift
//  TaskExpirationHandler
//
//  Created by Jaehong Kang on 2021/09/02.
//

import Foundation

public func withTaskExpirationHandler<T>(body: @escaping (@escaping @Sendable () -> Void) async -> T) async -> T {
    return await TaskExpirationHandler().run(body: body)
}

public func withTaskExpirationHandler<T>(body: @escaping (@escaping @Sendable () -> Void) async throws -> T) async throws -> T {
    return try await TaskExpirationHandler().run(body: body)
}

private actor TaskExpirationHandler {
    private let dispatchGroup = DispatchGroup()
    private var cancellationHandler: (() -> Void)?
}

extension TaskExpirationHandler {
    @Sendable
    nonisolated func cancel() {
        Task.detached(priority: .high) {
            await self.cancellationHandler?()
        }
        dispatchGroup.wait()
    }
}

extension TaskExpirationHandler {
    func run<T>(body: @escaping (@escaping @Sendable () -> Void) async throws -> T) async throws -> T {
        dispatchGroup.enter()
        let task = Task<T, Error> {
            defer {
                dispatchGroup.leave()
            }

            return try await body(self.cancel)
        }

        return try await withTaskCancellationHandler {
            self.cancellationHandler = task.cancel

            return try await task.value
        } onCancel: {
            task.cancel()
        }
    }
}

extension TaskExpirationHandler {
    func run<T>(body: @escaping (@escaping @Sendable () -> Void) async -> T) async -> T {
        dispatchGroup.enter()
        let task = Task<T, Never> {
            defer {
                dispatchGroup.leave()
            }

            return await body(self.cancel)
        }

        return await withTaskCancellationHandler {
            self.cancellationHandler = task.cancel

            return await task.value
        } onCancel: {
            task.cancel()
        }
    }
}
