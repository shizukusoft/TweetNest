//
//  DataAssetImage.swift
//  DataAssetImage
//
//  Created by Jaehong Kang on 2021/08/08.
//

import SwiftUI
import ImageIO
import UniformTypeIdentifiers
import TweetNestKit

struct DataAssetImage: View {
    let url: URL?
    let isExportable: Bool

    @StateObject private var dataAssetsFetchedResultsController: FetchedResultsController<TweetNestKit.DataAsset>

    private let operaionQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.qualityOfService = .userInteractive
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.name = String(describing: Self.self)

        return operationQueue
    }()

    @State private var data: Data?
    @State private var dataMIMEType: String?

    @State private var cgImage: CGImage?
    @State private var cgImageScale: CGFloat?

    @State private var isDetailProfileImagePresented: Bool = false

    var body: some View {
        let dataAsset = dataAssetsFetchedResultsController.fetchedObjects.first

        Group {
            if let cgImage = cgImage {
                image(for: cgImage)
            } else {
                Color.gray
            }
        }
        .onChange(of: dataAsset?.data) { newValue in
            updateImage(data: newValue)
        }
        .onAppear {
            updateImage(data: dataAsset?.data)
        }
        .onDisappear {
            operaionQueue.cancelAllOperations()
        }
    }

    @ViewBuilder func image(for cgImage: CGImage) -> some View {
        let image = Image(decorative: cgImage, scale: cgImageScale ?? 1.0)
            .interpolation(.high)
            .resizable()

        #if canImport(PDFKit)
        if isExportable, let data = data, let url = url {
            let utType = dataMIMEType.flatMap { UTType(mimeType: $0) }

            let filename: String = {
                if url.pathExtension.isEmpty, let utType = utType {
                    return url.appendingPathExtension(for: utType).lastPathComponent
                } else {
                    return url.lastPathComponent
                }
            }()

            Group {
                #if os(macOS)
                image
                    .onTapGesture {
                        isDetailProfileImagePresented = true
                    }
                    .contextMenu {
                        Button(
                            action: {
                                #if canImport(AppKit)
                                NSPasteboard.general.setData(data, forType: .fileContents)
                                #elseif canImport(UIKit)
                                UIPasteboard.general.image = UIImage(data: data)
                                #endif
                            },
                            label: {
                                Label("Copy", systemImage: "doc.on.doc")
                            }
                        )
                    }
                #else
                Menu {
                    Button(
                        action: {
                            #if canImport(AppKit)
                            NSPasteboard.general.setData(data, forType: .fileContents)
                            #elseif canImport(UIKit)
                            UIPasteboard.general.image = UIImage(data: data)
                            #endif
                        },
                        label: {
                            Label("Copy", systemImage: "doc.on.doc")
                        }
                    )
                } label: {
                    image
                } primaryAction: {
                    isDetailProfileImagePresented = true
                }
                #endif
            }
            .onDrag {
                let itemProvider = NSItemProvider(item: data as NSSecureCoding?, typeIdentifier: utType?.identifier)
                itemProvider.suggestedName = filename

                return itemProvider
            }
            .sheet(isPresented: $isDetailProfileImagePresented) {
                #if os(macOS)
                DetailImageView(imageData: data, image: cgImage, imageScale: cgImageScale ?? 1.0, filename: filename)
                    .frame(minWidth: 120, idealWidth: 410, minHeight: 120, idealHeight: 410)
                #else
                NavigationView {
                    DetailImageView(imageData: data, image: cgImage, imageScale: cgImageScale ?? 1.0, filename: filename)
                }
                #endif
            }
        } else {
            image
        }
        #else
        image
        #endif
    }

    init(url: URL?, isExportable: Bool = false) {
        self.url = url
        self.isExportable = isExportable

        let fetchRequest = TweetNestKit.DataAsset.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TweetNestKit.DataAsset.creationDate, ascending: false)]
        fetchRequest.predicate = url.flatMap { NSPredicate(format: "url == %@", $0 as NSURL) } ?? NSPredicate(value: false)
        fetchRequest.propertiesToFetch = ["data"]
        fetchRequest.fetchLimit = 1

        self._dataAssetsFetchedResultsController = StateObject(
            wrappedValue: FetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: TweetNestApp.session.persistentContainer.viewContext
            )
        )
    }

    private func updateImage(data: Data?) {
        let dataAsset = dataAssetsFetchedResultsController.fetchedObjects.first

        let data = dataAsset?.data
        let dataMIMEType = dataAsset?.dataMIMEType

        operaionQueue.addOperation {
            let cgImageAndScale: (CGImage, CGFloat?)? = data.flatMap {
                guard let imageSource = CGImageSourceCreateWithData(
                    $0 as CFData,
                    nil
                ) else {
                    return nil
                }

                guard let image = CGImageSourceCreateThumbnailAtIndex(
                    imageSource,
                    0,
                    [
                        kCGImageSourceCreateThumbnailFromImageAlways: true,
                        kCGImageSourceShouldCache as String: true,
                        kCGImageSourceShouldCacheImmediately as String: true,
                        kCGImageSourceCreateThumbnailWithTransform as String: true,
                    ] as CFDictionary
                ) else {
                    return nil
                }

                let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any]

                let imageDPI = [imageProperties?[kCGImagePropertyDPIWidth], imageProperties?[kCGImagePropertyDPIHeight]].compactMap { ($0 as? NSNumber)?.doubleValue }.min()

                return (image, imageDPI.flatMap { $0 / 72 })
            }

            DispatchQueue.main.async {
                self.data = data
                self.dataMIMEType = dataMIMEType
                self.cgImage = cgImageAndScale?.0
                self.cgImageScale = cgImageAndScale?.1
            }
        }
    }
}
