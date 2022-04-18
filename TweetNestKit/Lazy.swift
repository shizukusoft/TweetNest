//
//  Lazy.swift
//  TweetNestKit
//
//  Created by 강재홍 on 2022/04/18.
//

import Foundation

@propertyWrapper
open class Lazy<Value> {
    private enum Status {
        case uninitialized(() -> Value)
        case initialized(Value)
    }

    private var value: Status

    open var wrappedValue: Value {
        get {
            switch value {
            case .uninitialized(let initializer):
                let value = initializer()

                self.value = .initialized(value)

                return value
            case .initialized(let value):
                return value
            }
        }
        set {
            self.value = .initialized(newValue)
        }
    }

    public init(wrappedValue: @autoclosure @escaping () -> Value) {
        self.value = .uninitialized(wrappedValue)
    }

    open func reset(_ newValue: @autoclosure @escaping () -> Value) {
        self.value = .uninitialized(newValue)
    }
}

extension Lazy: ObservableObject where Value: ObservableObject {
    public var objectWillChange: Value.ObjectWillChangePublisher {
        self.wrappedValue.objectWillChange
    }
}
