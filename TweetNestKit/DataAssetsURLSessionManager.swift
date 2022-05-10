//
//  DataAssetsURLSessionManager.swift
//  TweetNestKit
//
//  Created by 강재홍 on 2022/04/19.
//

import Foundation
import BackgroundTask
import UnifiedLogging
import OrderedCollections
import CoreData

class DataAssetsURLSessionManager: NSObject {
    static let backgroundURLSessionIdentifier = Bundle.tweetNestKit.bundleIdentifier! + ".data-assets"

    @MainActor
    private var _backgroundURLSessionEventsCompletionHandler: (() -> Void)?
    @MainActor
    private var backgroundURLSessionEventsCompletionHandler: (() -> Void)? {
        let backgroundURLSessionEventsCompletionHandler = _backgroundURLSessionEventsCompletionHandler

        _backgroundURLSessionEventsCompletionHandler = nil

        return backgroundURLSessionEventsCompletionHandler
    }

    private var urlSessionConfiguration: URLSessionConfiguration {
        var urlSessionConfiguration: URLSessionConfiguration

        if isShared {
            urlSessionConfiguration = .twnk_background(withIdentifier: Self.backgroundURLSessionIdentifier)
        } else {
            urlSessionConfiguration = .twnk_default
        }

        urlSessionConfiguration.httpAdditionalHeaders = nil
        urlSessionConfiguration.sessionSendsLaunchEvents = true
        urlSessionConfiguration.waitsForConnectivity = true
        urlSessionConfiguration.allowsConstrainedNetworkAccess = false

        return urlSessionConfiguration
    }

    private let isShared: Bool

    private let dispatchGroup = DispatchGroup()
    private let logger = Logger(label: Bundle.tweetNestKit.bundleIdentifier!, category: String(reflecting: DataAssetsURLSessionManager.self))
    private let persistentContainer: PersistentContainer
    
    private lazy var urlSession = URLSession(configuration: urlSessionConfiguration, delegate: self, delegateQueue: nil)
    private lazy var managedObjectContext = persistentContainer.newBackgroundContext()

    init(isShared: Bool, persistentContainer: PersistentContainer) {
        self.isShared = isShared
        self.persistentContainer = persistentContainer

        super.init()

        _ = urlSession
    }

    @MainActor
    func handleBackgroundURLSessionEvents(completionHandler: @escaping () -> Void) {
        _backgroundURLSessionEventsCompletionHandler = completionHandler
    }

    func invalidate() {
        urlSession.invalidateAndCancel()
    }
}

extension DataAssetsURLSessionManager {
    struct DownloadRequest: Equatable, Hashable {
        var urlRequest: URLRequest
        var priority: Float
        var expectsToReceiveFileSize: Int64

        init(urlRequest: URLRequest, priority: Float = URLSessionTask.defaultPriority, expectsToReceiveFileSize: Int64 = NSURLSessionTransferSizeUnknown) {
            self.urlRequest = urlRequest
            self.priority = priority
            self.expectsToReceiveFileSize = expectsToReceiveFileSize
        }

        init(url: URL, priority: Float = URLSessionTask.defaultPriority, expectsToReceiveFileSize: Int64 = NSURLSessionTransferSizeUnknown) {
            let urlRequest = URLRequest(url: url)

            self.init(urlRequest: urlRequest, priority: priority, expectsToReceiveFileSize: expectsToReceiveFileSize)
        }
    }

    func download<S>(_ downloadRequests: S) async where S: Sequence, S.Element == DownloadRequest {
        let downloadRequests = OrderedSet(downloadRequests)

        return await withCheckedContinuation { [urlSession] continuation in
            urlSession.getTasksWithCompletionHandler { _, _, downloadTasks in
                let pendingDownloadTasks = Dictionary(
                    grouping: downloadTasks
                        .lazy
                        .filter {
                            switch $0.state {
                            case .running, .suspended:
                                return true
                            case .canceling, .completed:
                                return false
                            @unknown default:
                                return false
                            }
                        },
                    by: \.originalRequest
                )

                for downloadRequest in downloadRequests {
                    var urlRequest = downloadRequest.urlRequest
                    urlRequest.allowsExpensiveNetworkAccess = TweetNestKitUserDefaults.standard.downloadsDataAssetsUsingExpensiveNetworkAccess

                    let downloadTask = pendingDownloadTasks[urlRequest]?.last ?? urlSession.downloadTask(with: urlRequest)
                    downloadTask.countOfBytesClientExpectsToSend = 1024
                    downloadTask.countOfBytesClientExpectsToReceive = downloadRequest.expectsToReceiveFileSize
                    downloadTask.priority = downloadRequest.priority

                    downloadTask.resume()
                }

                continuation.resume()
            }
        }
    }
}

extension DataAssetsURLSessionManager: URLSessionDelegate {
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        dispatchGroup.notify(queue: .global(qos: .default)) {
            DispatchQueue.main.async {
                self.backgroundURLSessionEventsCompletionHandler?()
            }
        }
    }

    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        if let error = error {
            logger.error("\(error as NSError, privacy: .public)")
        }
    }
}

extension DataAssetsURLSessionManager: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            logger.error("\(error as NSError, privacy: .public)")
        }
    }
}

extension DataAssetsURLSessionManager: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let originalRequestURL = downloadTask.originalRequest?.url else { return }

        do {
            let data = try Data(contentsOf: location, options: .mappedIfSafe)

            dispatchGroup.enter()
            Task.detached { [dispatchGroup, managedObjectContext, logger] in
                defer {
                    dispatchGroup.leave()
                }

                while managedObjectContext.persistentStoreCoordinator?.persistentStores.isEmpty != false {
                    await Task.yield()
                }

                do {
                    try await managedObjectContext.perform(schedule: .enqueued) {
                        try withExtendedBackgroundExecution {
                            try DataAsset.dataAsset(data: data, dataMIMEType: downloadTask.response?.mimeType, url: originalRequestURL, context: managedObjectContext)

                            if managedObjectContext.hasChanges {
                                try managedObjectContext.save()
                            }
                        }
                    }
                } catch {
                    logger.error("\(error as NSError, privacy: .public)")
                }
            }
        } catch {
            logger.error("\(error as NSError, privacy: .public)")
        }
    }
}
