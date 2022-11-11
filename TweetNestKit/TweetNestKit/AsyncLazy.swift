//
//  AsyncLazy.swift
//  AsyncLazy
//
//  Created by Jaehong Kang on 2021/08/07.
//

import Foundation

actor AsyncLazy<Value> {
    enum Status {
        case uninitialized
        case initializing
        case initialized(Result<Value, Error>)
    }

    private let initializer: () async throws -> Value
    private var value: Status = .uninitialized

    var wrappedValue: Value {
        get async throws {
            while case .initializing = value {
                try Task.checkCancellation()
                await Task.yield()
            }

            switch value {
            case .uninitialized:
                self.value = .initializing

                do {
                    let value = try await initializer()
                    self.value = .initialized(.success(value))
                } catch {
                    self.value = .initialized(.failure(error))
                }

                return try await self.wrappedValue
            case .initializing:
                return try await self.wrappedValue
            case .initialized(let result):
                return try result.get()
            }
        }
    }

    init(_ initializer: @escaping () async throws -> Value) {
        self.initializer = initializer
    }
}
