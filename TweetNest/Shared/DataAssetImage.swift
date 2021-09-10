//
//  DataAssetImage.swift
//  DataAssetImage
//
//  Created by Jaehong Kang on 2021/08/08.
//

import SwiftUI
import TweetNestKit

struct DataAssetImage<Content>: View where Content: View {
    @FetchRequest private var dataAssets: FetchedResults<TweetNestKit.DataAsset>

    private let queue = DispatchQueue(label: String(describing: Self.self), qos: .userInteractive)
    @State private var image: Image?

    var contentInitializer: (Image?) -> Content

    var body: some View {
        contentInitializer(image)
            .onChange(of: dataAssets.first?.data) { _ in
                updateImage()
            }
            .onAppear {
                updateImage()
            }
    }

    init(url: URL?, @ViewBuilder content: @escaping (Image?) -> Content) {
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

    private func updateImage() {
        queue.async {
            let image = Image(data: dataAssets.first?.data)

            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
}
