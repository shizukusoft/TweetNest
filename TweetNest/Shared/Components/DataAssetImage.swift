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

    @StateObject private var dataAssetsFetchedResultsController: FetchedResultsController<DataAsset>

    struct ImageData: Equatable {
        var data: Data
        var dataMIMEType: String
    }
    @State private var imageData: ImageData?

    @State private var dispatchQueue = DispatchQueue(
        label: String(reflecting: Self.self),
        qos: .userInitiated
    )
    @State private var cgImage: CGImage?
    @State private var cgImageScale: CGFloat?

    @State private var isDetailProfileImagePresented: Bool = false

    var body: some View {
        Group {
            #if os(macOS) || os(iOS)
            if isExportable, let url = url, let cgImage = cgImage, let imageData = imageData, let utType = UTType(mimeType: imageData.dataMIMEType, conformingTo: .image) {
                let filename = url.pathExtension.isEmpty ? url.appendingPathExtension(for: utType).lastPathComponent : url.lastPathComponent

                Group {
                    #if os(macOS)
                    resizableImage(cgImage, scale: cgImageScale)
                        .onTapGesture {
                            isDetailProfileImagePresented = true
                        }
                        .contextMenu {
                            menuItems(imageData: imageData.data)
                        }
                    #else
                    Menu {
                        menuItems(imageData: imageData.data)
                    } label: {
                        resizableImage(cgImage, scale: cgImageScale)
                    } primaryAction: {
                        isDetailProfileImagePresented = true
                    }
                    .menuStyle(.borderlessButton)
                    #endif
                }
                .onDrag {
                    let itemProvider = NSItemProvider()
                    itemProvider.registerDataRepresentation(forTypeIdentifier: utType.identifier, visibility: .all) { loadHandler in
                        loadHandler(imageData.data, nil)
                        return nil
                    }
                    itemProvider.suggestedName = filename

                    return itemProvider
                } preview: {
                    Image(decorative: cgImage, scale: cgImageScale ?? 1.0)
                }
                .sheet(isPresented: $isDetailProfileImagePresented) {
                    #if os(macOS)
                    DetailImageView(imageData: imageData.data, image: cgImage, imageScale: cgImageScale ?? 1.0, filename: filename)
                        .frame(minWidth: 120, idealWidth: 410, minHeight: 120, idealHeight: 410)
                    #else
                    NavigationView {
                        DetailImageView(imageData: imageData.data, image: cgImage, imageScale: cgImageScale ?? 1.0, filename: filename)
                    }
                    #endif
                }
            } else {
                resizableImage(cgImage, scale: cgImageScale)
            }
            #else
            resizableImage(cgImage, scale: cgImageScale)
            #endif
        }
        .onChange(of: dataAssetsFetchedResultsController.fetchedObjects.first) { newValue in
            updateImage(
                from: newValue?.data.flatMap { data in
                    newValue?.dataMIMEType.flatMap { dataMIMEType in
                        ImageData(
                            data: data,
                            dataMIMEType: dataMIMEType
                        )
                    }
                }
            )
        }
        .onAppear {
            updateImage(
                from: dataAssetsFetchedResultsController.fetchedObjects.first?.data.flatMap { data in
                    dataAssetsFetchedResultsController.fetchedObjects.first?.dataMIMEType.flatMap { dataMIMEType in
                        ImageData(
                            data: data,
                            dataMIMEType: dataMIMEType
                        )
                    }
                }
            )
        }
    }

    init(url: URL?, isExportable: Bool = false) {
        self.url = url
        self.isExportable = isExportable

        self._dataAssetsFetchedResultsController = StateObject(
            wrappedValue: FetchedResultsController<DataAsset>(
                fetchRequest: {
                    let fetchRequest: NSFetchRequest<DataAsset> = DataAsset.fetchRequest()
                    fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TweetNestKit.DataAsset.creationDate, ascending: false)]
                    fetchRequest.predicate = url.flatMap { NSPredicate(format: "url == %@", $0 as NSURL) } ?? NSPredicate(value: false)
                    fetchRequest.propertiesToFetch = ["data", "dataMIMEType"]
                    fetchRequest.returnsObjectsAsFaults = false
                    fetchRequest.fetchLimit = 1

                    return fetchRequest
                }(),
                managedObjectContext: TweetNestApp.session.persistentContainer.viewContext
            )
        )
    }

    @ViewBuilder
    private func resizableImage(_ cgImage: CGImage?, scale: CGFloat?) -> some View {
        if let cgImage = cgImage {
            Image(decorative: cgImage, scale: scale ?? 1.0)
                #if !os(watchOS)
                .interpolation(.high)
                #else
                .interpolation(.medium)
                #endif
                .resizable()
        } else {
            Color.gray
        }
    }

    @ViewBuilder
    private func menuItems(imageData: Data) -> some View {
        Button(
            action: {
                #if canImport(AppKit)
                NSPasteboard.general.setData(imageData, forType: .fileContents)
                #elseif canImport(UIKit) && !os(watchOS)
                UIPasteboard.general.image = UIImage(data: imageData)
                #endif
            },
            label: {
                Label("Copy", systemImage: "doc.on.doc")
            }
        )
    }

    private func updateImage(from imageData: ImageData?) {
        dispatchQueue.async {
            let cgImageAndImageScale: (cgImage: CGImage, imageScale: CGFloat?)? = {
                guard let imageData = imageData else {
                    return nil
                }

                guard let imageSource = CGImageSourceCreateWithData(
                    imageData.data as CFData,
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

                return (cgImage: image, imageScale: imageDPI.flatMap { $0 / 72 })
            }()

            Task {
                self.imageData = imageData
                self.cgImage = cgImageAndImageScale?.cgImage
                self.cgImageScale = cgImageAndImageScale?.imageScale
            }
        }
    }
}
