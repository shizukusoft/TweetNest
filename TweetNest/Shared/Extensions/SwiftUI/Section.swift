//
//  Section.swift
//  Section
//
//  Created by Mina Her on 2021/08/08.
//

import SwiftUI

extension Section
where Content: View,
      Footer == EmptyView
{

    init<T, I>(_ header: @autoclosure () -> Label<T, I>, content: () -> Content)
    where T: View,
          I: View,
          Parent == Label<T, I>
    {
        self.init(content: content, header: header)
    }
}

extension Section
where Content: View,
      Parent == Text,
      Footer == EmptyView
{

    init(_ header: @autoclosure () -> Text, content: () -> Content) {
        self.init(content: content, header: header)
    }
}
