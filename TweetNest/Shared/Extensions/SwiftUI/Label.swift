//
//  Label.swift
//  Label
//
//  Created by Mina Her on 2021/08/08.
//

import SwiftUI

extension Label
where Title == Text,
      Icon == Image
{

    init(_ title: @autoclosure () -> Text, systemImage name: String) {
        let icon = {Image(systemName: name)}
        self.init(title: title, icon: icon)
    }
}

extension Label
where Title == Text {

    init(_ title: @autoclosure () -> Text, icon: () -> Icon) {
        self.init(title: title, icon: icon)
    }
}
