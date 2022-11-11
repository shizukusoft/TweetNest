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
                do {
                    return try JSONDecoder().decode(NavigationSplitViewVisibility.self, from: $0)
                } catch {
                    fatalError(error.localizedDescription)
                }
            } ?? .automatic
        }
        set {
            do {
                self.data = try JSONEncoder().encode(newValue)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }

    init() { }

    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    init(_ value: NavigationSplitViewVisibility) {
        self.init()

        self.value = value
    }
}
