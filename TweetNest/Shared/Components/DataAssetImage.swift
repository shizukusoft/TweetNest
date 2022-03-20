//
//  DataAssetImage.swift
//  DataAssetImage
//
//  Created by Jaehong Kang on 2021/08/08.
//

import SwiftUI
import ImageIO
import UniformTypeIdentifiers
import CoreData
import TweetNestKit
import UnifiedLogging

struct DataAssetImage: View {
    let url: URL?
    let isExportable: Bool

    private class Store: NSObject, NSFetchedResultsControllerDelegate, ObservableObject  {
        static let managedObjectContext = TweetNestApp.session.persistentContainer.viewContext

        let url: URL?

        private var updateImageTask: Task<Void, Never>?

        struct ImageInfo {
            var cgImage: CGImage?
            var cgImageScale: CGFloat?
            var data: Data?
            var dataMIMEType: String?
        }
        @Published private(set) var imageInfo: ImageInfo

        private lazy var fetchedResultsController: NSFetchedResultsController<DataAsset> = {
            let fetchedResultsController = NSFetchedResultsController<DataAsset>(
                fetchRequest: {
                    let fetchRequest: NSFetchRequest<DataAsset> = DataAsset.fetchRequest()
                    fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TweetNestKit.DataAsset.creationDate, ascending: false)]
                    fetchRequest.predicate = url.flatMap { NSPredicate(format: "url == %@", $0 as NSURL) } ?? NSPredicate(value: false)
                    fetchRequest.propertiesToFetch = ["data", "dataMIMEType"]
                    fetchRequest.returnsObjectsAsFaults = false
                    fetchRequest.fetchLimit = 1

                    return fetchRequest
                }(),
                managedObjectContext: Self.managedObjectContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )

            fetchedResultsController.delegate = self

            return fetchedResultsController
        }()

        private var dataAsset: DataAsset? {
            self.fetchedResultsController.fetchedObjects?.first
        }

        init(url: URL?) {
            self.url = url
            self.imageInfo = ImageInfo()

            super.init()
        }

        deinit {
            updateImageTask?.cancel()
        }

        func fetch() {
            guard url != nil && fetchedResultsController.fetchedObjects == nil else {
                return
            }

            Self.managedObjectContext.performAndWait {
                do {
                    try self.fetchedResultsController.performFetch()
                    updateImageInfo()
                } catch {
                    Logger().error("Error occured on \(DataAssetImage.Store.self):\n\(error as NSError)")
                }
            }
        }

        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            updateImageInfo()
        }

        private func updateImageInfo() {
            let dataAsset = dataAsset

            let data = dataAsset?.data
            let dataMIMEType = dataAsset?.dataMIMEType

            self.updateImageTask?.cancel()
            self.updateImageTask = Task.detached(priority: .userInitiated) {
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

                guard Task.isCancelled == false else { return }

                await MainActor.run {
                    self.imageInfo = ImageInfo(
                        cgImage: cgImageAndScale?.0,
                        cgImageScale: cgImageAndScale?.1,
                        data: data,
                        dataMIMEType: dataMIMEType
                    )
                    self.updateImageTask = nil
                }
            }
        }
    }

    @StateObject private var store: Store

    @State private var isDetailProfileImagePresented: Bool = false

    @ViewBuilder var image: some View {
        let imageInfo = store.imageInfo

        if let cgImage = imageInfo.cgImage {
            Image(decorative: cgImage, scale: imageInfo.cgImageScale ?? 1.0)
                .interpolation(.high)
                .resizable()
        } else {
            Color.gray
        }
    }

    var body: some View {
        let imageInfo = store.imageInfo

        Group {
            #if canImport(PDFKit)
            if isExportable, let data = imageInfo.data, let cgImage = imageInfo.cgImage, let url = url {
                let utType = imageInfo.dataMIMEType.flatMap { UTType(mimeType: $0) }

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
                    DetailImageView(imageData: data, image: cgImage, imageScale: imageInfo.cgImageScal ?? 1.0, filename: filename)
                        .frame(minWidth: 120, idealWidth: 410, minHeight: 120, idealHeight: 410)
                    #else
                    NavigationView {
                        DetailImageView(imageData: data, image: cgImage, imageScale: imageInfo.cgImageScale ?? 1.0, filename: filename)
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
        .onAppear {
            store.fetch()
        }
    }

    init(url: URL?, isExportable: Bool = false) {
        self.url = url
        self.isExportable = isExportable

        self._store = StateObject(
            wrappedValue: Store(url: url)
        )
    }
}
