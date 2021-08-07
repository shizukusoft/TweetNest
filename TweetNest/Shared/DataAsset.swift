//
//  DataAsset.swift
//  DataAsset
//
//  Created by Jaehong Kang on 2021/08/08.
//

import SwiftUI
import TweetNestKit

struct DataAsset<Content>: View where Content: View {
    @FetchRequest private var dataAssets: FetchedResults<TweetNestKit.DataAsset>

    var contentInitializer: (Data?) -> Content

    var body: some View {
        contentInitializer(dataAssets.last?.data)
    }

    init(url: URL?, @ViewBuilder content: @escaping (Data?) -> Content) {
        self._dataAssets = FetchRequest(
            sortDescriptors: [SortDescriptor(\.creationDate)],
            predicate: url.flatMap { NSPredicate(format: "url == %@", $0 as NSURL) } ?? NSPredicate(format: "false"),
            animation: .default
        )
        self.contentInitializer = content
    }
}
