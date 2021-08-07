//
//  AsyncLazy.swift
//  AsyncLazy
//
//  Created by Jaehong Kang on 2021/08/07.
//

import Foundation

enum AsyncLazy<Value> {
    case uninitialized(() async throws -> Value)
    case initialized(Value)
}
