//
//  Button.swift
//  Button
//
//  Created by Mina Her on 2021/08/08.
//

import SwiftUI

extension Button {

    init<T, I>(_ label: @autoclosure () -> SwiftUI.Label<T, I>, action: @escaping () -> Void)
    where T: View,
          I: View,
          Label == SwiftUI.Label<T, I>
    {
        self.init(action: action, label: label)
    }
}

extension Button
where Label == Text {

    init(_ label: @autoclosure () -> Text, action: @escaping () -> Void) {
        self.init(action: action, label: label)
    }

    init(_ label: @autoclosure () -> Text, role: ButtonRole?, action: @escaping () -> Void) {
        self.init(role: role, action: action, label: label)
    }
}
