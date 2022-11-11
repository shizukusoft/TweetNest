//
//  DateFormatter+TweetNestKit.swift
//  TweetNestKit
//
//  Created by Jaehong Kang on 2022/08/17.
//

import Foundation

extension DateFormatter {
    class var http: Self {
        let dateFormatter = self.init()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss O"
        dateFormatter.timeZone = .init(secondsFromGMT: 0)

        return dateFormatter
    }
}
