//
//  TweetNestWatchLabelStyle.swift
//  TweetNestWatchLabelStyle
//
//  Created by Jaehong Kang on 2021/08/27.
//

import SwiftUI

struct TweetNestWatchLabelStyle: LabelStyle {
    let iconSize: CGFloat?

    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .center, spacing: nil) {
            Group {
                if let iconSize = iconSize {
                    configuration.icon
                        .frame(width: iconSize, height: iconSize, alignment: .center)
                } else {
                    configuration.icon
                }
            }
            .tint(.accentColor)

            configuration.title
                .multilineTextAlignment(.leading)
                .tint(.primary)
        }
    }

    init(iconSize: CGFloat? = nil) {
        self.iconSize = iconSize
    }
}

struct TweetNestWatchLabelStyle_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VStack {
                NavigationLink {
                    EmptyView()
                } label: {
                    Label(Text(verbatim: "Lorem ipsum dolor sit amet, consectetur adipiscing elit."), systemImage: "plus")
                        .labelStyle(TweetNestWatchLabelStyle())
                }
                Label(Text(verbatim: "Lorem ipsum dolor sit amet, consectetur adipiscing elit."), systemImage: "person.3")
                    .labelStyle(TweetNestWatchLabelStyle())
                Label(Text(verbatim: "Lorem ipsum dolor sit amet, consectetur adipiscing elit."), systemImage: "person")
                    .labelStyle(TweetNestWatchLabelStyle())
            }
        }
    }
}
