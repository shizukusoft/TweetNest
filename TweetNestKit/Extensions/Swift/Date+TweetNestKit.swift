//
//  Date+TweetNestKit.swift
//  TweetNestKit
//
//  Created by Jaehong Kang on 2021/09/26.
//

import Foundation

extension Date {
    public func twnk_formatted(date: Date.FormatStyle.DateStyle? = nil, time: Date.FormatStyle.TimeStyle? = nil, compact: Bool) -> String {
        formatted(
            date: date ?? (compact ? .numeric : .long),
            time: time ?? (compact ? .shortened : .standard)
        )
    }
}
