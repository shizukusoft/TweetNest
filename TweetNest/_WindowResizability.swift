//
//  _WindowResizability.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2022/10/24.
//

import SwiftUI

#if os(macOS)

enum _WindowResizability {
    /// Automatic window resizability.
    ///
    /// For the `WindowGroup`, `Window` and `DocumentGroup` scenes, the minimum
    /// size of their content will be the minimum size of the window. The window
    /// will have no maximum size.
    ///
    /// For `Settings`, the window will have a minimum and maximum size based
    /// on its contents.
    case automatic

    /// A window resizability derived from the contents of the window.
    ///
    /// Windows will have a minimum and maximum size based on the minimum and
    /// maximum size of their contents.
    case contentSize

    /// A window resizability derived from the minimum size of the window
    /// contents.
    ///
    /// Windows will have a minimum size based on their contents, and no maximum
    /// size.
    case contentMinSize

    @available(macOS 13.0, *)
    var windowResizability: WindowResizability {
        switch self {
        case .automatic:
            return .automatic
        case .contentSize:
            return .contentSize
        case .contentMinSize:
            return .contentMinSize
        }
    }
}

extension Scene {
    func _windowResizability(_ resizability: _WindowResizability) -> some Scene {
        if #available(macOS 13.0, *) {
            return self.windowResizability(resizability.windowResizability)
        } else {
            return self
        }
    }
}

#endif
