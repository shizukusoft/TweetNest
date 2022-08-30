//
//  _NavigationSplitViewVisibility.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2022/08/28.
//

import SwiftUI

@available(iOS, deprecated: 16.0)
@available(macOS, deprecated: 13.0)
@available(watchOS, deprecated: 9.0)
@available(tvOS, deprecated: 16.0)
struct _NavigationSplitViewVisibility {
    private var data: Data?

    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    var value: NavigationSplitViewVisibility {
        get {
            data.flatMap {
                try! JSONDecoder().decode(NavigationSplitViewVisibility.self, from: $0)
            } ?? .automatic
        }
        set {
            self.data = try! JSONEncoder().encode(newValue)
        }
    }

    init() { }

    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    init(_ value: NavigationSplitViewVisibility) {
        self.init()

        self.value = value
    }
}
