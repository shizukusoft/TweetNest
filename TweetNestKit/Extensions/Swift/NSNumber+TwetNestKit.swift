//
//  NSNumber+TwetNestKit.swift
//  NSNumber+TwetNestKit
//
//  Created by Jaehong Kang on 2021/08/29.
//

import Foundation

private var numberFormatter: NumberFormatter {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    
    return numberFormatter
}

extension Int {
    public func twnk_formatted() -> String {
        numberFormatter.string(from: NSNumber(value: self)) ?? String(self)
    }
}

extension UInt {
    public func twnk_formatted() -> String {
        numberFormatter.string(from: NSNumber(value: self)) ?? String(self)
    }
}

extension Int8 {
    public func twnk_formatted() -> String {
        numberFormatter.string(from: NSNumber(value: self)) ?? String(self)
    }
}

extension UInt8 {
    public func twnk_formatted() -> String {
        numberFormatter.string(from: NSNumber(value: self)) ?? String(self)
    }
}

extension Int16 {
    public func twnk_formatted() -> String {
        numberFormatter.string(from: NSNumber(value: self)) ?? String(self)
    }
}

extension UInt16 {
    public func twnk_formatted() -> String {
        numberFormatter.string(from: NSNumber(value: self)) ?? String(self)
    }
}

extension Int32 {
    public func twnk_formatted() -> String {
        numberFormatter.string(from: NSNumber(value: self)) ?? String(self)
    }
}

extension UInt32 {
    public func twnk_formatted() -> String {
        numberFormatter.string(from: NSNumber(value: self)) ?? String(self)
    }
}

extension Int64 {
    public func twnk_formatted() -> String {
        numberFormatter.string(from: NSNumber(value: self)) ?? String(self)
    }
}

extension UInt64 {
    public func twnk_formatted() -> String {
        numberFormatter.string(from: NSNumber(value: self)) ?? String(self)
    }
}
