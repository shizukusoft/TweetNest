//
//  Date+TweetNestKit.swift
//  TweetNestKit
//
//  Created by Jaehong Kang on 2021/09/26.
//

import Foundation

extension Date {
    public func twnk_formatted(shouldCompact: Bool, date: Date.FormatStyle.DateStyle? = nil, time: Date.FormatStyle.TimeStyle? = nil) -> String {
        formatted(
            FormatStyle(
                twnk_shouldCompact: shouldCompact,
                date: date,
                time: time
            )
        )
    }
}

extension Date.FormatStyle {
    public init(twnk_shouldCompact shouldCompact: Bool, date: Date.FormatStyle.DateStyle? = nil, time: Date.FormatStyle.TimeStyle? = nil, locale: Locale = .autoupdatingCurrent, calendar: Calendar = .autoupdatingCurrent, timeZone: TimeZone = .autoupdatingCurrent, capitalizationContext: FormatStyleCapitalizationContext = .unknown) {
        self.init(
            date: date ?? (shouldCompact ? .numeric : .long),
            time: time ?? (shouldCompact ? .shortened : .standard),
            locale: locale,
            calendar: calendar,
            timeZone: timeZone,
            capitalizationContext: capitalizationContext
        )
    }
}
