//
//  NavigationLink.swift
//  NavigationLink
//
//  Created by Mina Her on 2021/08/08.
//

import SwiftUI

extension NavigationLink {

    init<T, I>(_ label: @autoclosure () -> SwiftUI.Label<T, I>, destination: () -> Destination)
    where T: View,
          I: View,
          Label == SwiftUI.Label<T, I>
    {
        self.init(destination: destination, label: label)
    }

    init<T, I>(_ label: @autoclosure () -> SwiftUI.Label<T, I>, isActive: Binding<Bool>, destination: () -> Destination)
    where T: View,
          I: View,
          Label == SwiftUI.Label<T, I>
    {
        self.init(isActive: isActive, destination: destination, label: label)
    }

    init<T, I, V>(_ label: @autoclosure () -> SwiftUI.Label<T, I>, tag: V, selection: Binding<V?>, destination: () -> Destination)
    where T: View,
          I: View,
          V: Hashable,
          Label == SwiftUI.Label<T, I>
    {
        self.init(tag: tag, selection: selection, destination: destination, label: label)
    }
}

extension NavigationLink
where Label == Text {

    init(_ label: @autoclosure () -> Text, destination: () -> Destination) {
        self.init(destination: destination, label: label)
    }

    init(_ label: @autoclosure () -> Text, isActive: Binding<Bool>, destination: () -> Destination) {
        self.init(isActive: isActive, destination: destination, label: label)
    }

    init<V>(_ label: @autoclosure () -> Text, tag: V, selection: Binding<V?>, destination: () -> Destination)
    where V: Hashable {
        self.init(tag: tag, selection: selection, destination: destination, label: label)
    }
}
