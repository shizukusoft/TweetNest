//
//  UserDetailLabelStyle.swift
//  TweetNest
//
//  Created by 강재홍 on 2022/05/09.
//

import SwiftUI

struct UserDetailLabelStyle: LabelStyle {
    let iconWidth: CGFloat?
    let iconHeight: CGFloat?

    @ViewBuilder
    func makeBody(configuration: Self.Configuration) -> some View {
        Label {
            configuration.title
        } icon: {
            configuration.icon
                .frame(width: iconWidth, height: iconHeight)

        }
        .labelStyle(.titleAndIcon)
    }
}

extension LabelStyle where Self == UserDetailLabelStyle {
    static func userDetailLabelStyle(iconWidth: CGFloat?, iconHeight: CGFloat?) -> UserDetailLabelStyle {
        .init(iconWidth: iconWidth, iconHeight: iconHeight)
    }
}
