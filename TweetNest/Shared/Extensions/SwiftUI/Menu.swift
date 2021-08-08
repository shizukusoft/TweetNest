//
//  Menu.swift
//  Menu
//
//  Created by Mina Her on 2021/08/08.
//

import SwiftUI

extension Menu {

    init<T, I>(_ label: @autoclosure () -> SwiftUI.Label<T, I>, content: () -> Content)
    where T: View,
          I: View,
          Label == SwiftUI.Label<T, I>
    {
        self.init(content: content, label: label)
    }

    init<T, I>(_ label: @autoclosure () -> SwiftUI.Label<T, I>, content: () -> Content, primaryAction: @escaping () -> Void)
    where T: View,
          I: View,
          Label == SwiftUI.Label<T, I>
    {
        self.init(content: content, label: label, primaryAction: primaryAction)
    }
}

extension Menu
where Label == Text {

    init(_ label: @autoclosure () -> Text, content: () -> Content) {
        self.init(content: content, label: label)
    }

    init(_ label: @autoclosure () -> Text, content: () -> Content, primaryAction: @escaping () -> Void) {
        self.init(content: content, label: label, primaryAction: primaryAction)
    }
}
