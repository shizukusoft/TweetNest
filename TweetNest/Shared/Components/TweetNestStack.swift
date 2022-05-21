//
//  TweetNestStack.swift
//  TweetNestStack
//
//  Created by Jaehong Kang on 2021/08/28.
//

import SwiftUI

struct TweetNestStack<Content>: View where Content: View {
    let spacing: CGFloat?
    let content: Content

    var body: some View {
        #if os(watchOS)
        VStack(alignment: .leading, spacing: spacing, content: { content })
        #else
        HStack(alignment: .center, spacing: spacing, content: { content })
        #endif
    }

    init(spacing: CGFloat? = nil, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }
}

#if DEBUG
struct TweetNestStack_Previews: PreviewProvider {

    static var previews: some View {
        List {
            Section {
                Label(
                    title: {
                        TweetNestStack {
                            Text(verbatim: "Title")
                            Spacer()
                            Text(verbatim: "Description")
                            .foregroundColor(.secondary)
                        }
                    },
                    icon: {
                        Image(systemName: "pentagon")
                    })
            }
            Section {
                Label(
                    title: {
                        TweetNestStack {
                            Text(verbatim: "John Appleseed")
                            Text(verbatim: "@johnny")
                            .foregroundColor(.secondary)
                        }
                    },
                    icon: {
                        Image(systemName: "circle.fill")
                    })
            }
        }
    }
}
#endif
