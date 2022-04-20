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
        case initialized(Value)
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
                let value = try await initializer()
                self.value = .initialized(value)

                return value
            case .initializing:
                return try await self.wrappedValue
            case .initialized(let value):
                return value
            }
        }
    }

    init(_ initializer: @escaping () async throws -> Value) {
        self.initializer = initializer
    }
}
