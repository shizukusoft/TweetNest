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
        contentInitializer(dataAssets.first?.data)
    }

    init(url: URL?, @ViewBuilder content: @escaping (Data?) -> Content) {
        let fetchRequest = TweetNestKit.DataAsset.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TweetNestKit.DataAsset.creationDate, ascending: false)]
        fetchRequest.predicate = url.flatMap { NSPredicate(format: "url == %@", $0 as NSURL) } ?? NSPredicate(value: false)
        fetchRequest.fetchLimit = 1

        self._dataAssets = FetchRequest(
            fetchRequest: fetchRequest,
            animation: .default
        )
        self.contentInitializer = content
    }
}
