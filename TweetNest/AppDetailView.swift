//
//  AppDetailView.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2022/09/03.
//

import SwiftUI

struct AppDetailView: View {
    var body: some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            _NavigationStack()
        }
    }
}

extension AppDetailView {
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    struct _NavigationStack: View {
        @State private var navigationPath = NavigationPath()

        var body: some View {
            NavigationStack(path: $navigationPath) {

            }
        }
    }
}

struct AppDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AppDetailView()
    }
}
