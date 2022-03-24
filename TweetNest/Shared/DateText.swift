//
//  DateText.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/10/05.
//

import SwiftUI

struct DateText: View {
    let date: Date

    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif

    var body: some View {
        #if os(iOS)
        Text(date, format: Date.FormatStyle(twnk_shouldCompact: horizontalSizeClass == .compact))
        #elseif os(watchOS)
        Text(date, format: Date.FormatStyle(twnk_shouldCompact: true))
        #else
        Text(date, format: Date.FormatStyle(twnk_shouldCompact: false))
        #endif
    }
}

struct DateText_Previews: PreviewProvider {
    static var previews: some View {
        DateText(date: Date())
    }
}
