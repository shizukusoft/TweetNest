//
//  DataAssetsURLSessionManager.swift
//  TweetNestKit
//
//  Created by 강재홍 on 2022/04/19.
//

import Foundation
import BackgroundTask
import UnifiedLogging
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
        urlSessionConfiguration.waitsForConnectivity = true
        urlSessionConfiguration.allowsConstrainedNetworkAccess = false

        return urlSessionConfiguration
    }

    private let isShared: Bool

    private let dispatchGroup = DispatchGroup()
    private let logger = Logger(label: Bundle.tweetNestKit.bundleIdentifier!, category: String(reflecting: DataAssetsURLSessionManager.self))
    private let managedObjectContext: NSManagedObjectContext

    private lazy var urlSession = URLSession(configuration: urlSessionConfiguration, delegate: self, delegateQueue: nil)

    init(isShared: Bool, managedObjectContext: NSManagedObjectContext) {
        self.isShared = isShared
        self.managedObjectContext = managedObjectContext

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
    func download(_ url: URL, expectsToReceiveFileSize: Int64 = NSURLSessionTransferSizeUnknown) {
        var urlRequest = URLRequest(url: url)
        urlRequest.allowsExpensiveNetworkAccess = TweetNestKitUserDefaults.standard.downloadsDataAssetsUsingExpensiveNetworkAccess

        let downloadTask = urlSession.downloadTask(with: urlRequest)
        downloadTask.countOfBytesClientExpectsToSend = 1024
        downloadTask.countOfBytesClientExpectsToReceive = expectsToReceiveFileSize

        downloadTask.resume()
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
            managedObjectContext.perform { [dispatchGroup, managedObjectContext, logger] in
                defer {
                    dispatchGroup.leave()
                }

                do {
                    try DataAsset.dataAsset(data: data, dataMIMEType: downloadTask.response?.mimeType, url: originalRequestURL, context: managedObjectContext)

                    if managedObjectContext.hasChanges {
                        try withExtendedBackgroundExecution {
                            try managedObjectContext.save()
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
