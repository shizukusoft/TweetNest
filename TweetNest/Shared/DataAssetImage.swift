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

    private let operaionQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.qualityOfService = .userInteractive
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.name = String(describing: Self.self)

        return operationQueue
    }()
    @State private var image: Image?

    var contentInitializer: (Image?) -> Content

    var body: some View {
        contentInitializer(image)
            .onChange(of: dataAssets.first?.data) { newValue in
                updateImage(data: newValue)
            }
            .onAppear {
                updateImage(data: dataAssets.first?.data)
            }
            .onDisappear {
                operaionQueue.cancelAllOperations()
            }
    }

    init(url: URL?, @ViewBuilder content: @escaping (Image?) -> Content) {
        let fetchRequest = TweetNestKit.DataAsset.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TweetNestKit.DataAsset.creationDate, ascending: false)]
        fetchRequest.predicate = url.flatMap { NSPredicate(format: "url == %@", $0 as NSURL) } ?? NSPredicate(value: false)
        fetchRequest.propertiesToFetch = ["data"]
        fetchRequest.fetchLimit = 1

        self._dataAssets = FetchRequest(
            fetchRequest: fetchRequest,
            animation: .default
        )
        self.contentInitializer = content
    }

    private func updateImage(data: Data?) {
        let data = dataAssets.first?.data

        operaionQueue.addOperation {
            let image = Image(data: data)

            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
}
