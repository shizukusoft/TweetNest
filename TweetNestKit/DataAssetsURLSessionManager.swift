//
//  DataAssetsURLSessionManager.swift
//  TweetNestKit
//
//  Created by 강재홍 on 2022/04/19.
//

import Foundation
import BackgroundTask
import UnifiedLogging

class DataAssetsURLSessionManager: NSObject {
    static let backgroundURLSessionIdentifier = Bundle.tweetNestKit.bundleIdentifier! + ".data-assets"

    private var _backgroundURLSessionEventsCompletionHandler: (() -> Void)?
    private var backgroundURLSessionEventsCompletionHandler: (() -> Void)? {
        let backgroundURLSessionEventsCompletionHandler = _backgroundURLSessionEventsCompletionHandler

        _backgroundURLSessionEventsCompletionHandler = nil

        return backgroundURLSessionEventsCompletionHandler
    }

    private var urlSessionConfiguration: URLSessionConfiguration {
        if session === Session.shared {
            return .twnk_background(withIdentifier: Self.backgroundURLSessionIdentifier)
        } else {
            return .twnk_default
        }
    }

    private unowned let session: Session
    private let dispatchGroup = DispatchGroup()
    private lazy var urlSession = URLSession(configuration: urlSessionConfiguration, delegate: self, delegateQueue: nil)
    private lazy var managedObjectContext = session.persistentContainer.newBackgroundContext()
    private lazy var logger = Logger(label: Bundle.tweetNestKit.bundleIdentifier!, category: String(reflecting: Self.self))

    init(session: Session) {
        self.session = session

        super.init()

        _ = urlSession
    }

    deinit {
        urlSession.invalidateAndCancel()
    }

    func handleBackgroundURLSessionEvents(completionHandler: @escaping () -> Void) {
        _backgroundURLSessionEventsCompletionHandler = completionHandler
    }
}

extension DataAssetsURLSessionManager {
    func download(_ url: URL) {
        var urlRequest = URLRequest(url: url)
        urlRequest.allowsExpensiveNetworkAccess = TweetNestKitUserDefaults.standard.downloadsDataAssetsUsingExpensiveNetworkAccess

        let downloadTask = urlSession.downloadTask(with: urlRequest)
        downloadTask.countOfBytesClientExpectsToSend = 1024
        downloadTask.countOfBytesClientExpectsToReceive = 3 * 1024 * 1024

        downloadTask.resume()
    }
}

extension DataAssetsURLSessionManager: URLSessionDelegate {
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        dispatchGroup.notify(queue: .main) { [backgroundURLSessionEventsCompletionHandler] in
            backgroundURLSessionEventsCompletionHandler?()
        }
    }

    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        if let error = error {
            self.logger.error("\(error as NSError, privacy: .public)")
        }
    }
}

extension DataAssetsURLSessionManager: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            self.logger.error("\(error as NSError, privacy: .public)")
        }
    }
}

extension DataAssetsURLSessionManager: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let originalRequestURL = downloadTask.originalRequest?.url else { return }

        do {
            let data = try Data(contentsOf: location, options: .mappedIfSafe)

            DispatchQueue.global(qos: .utility).async(group: dispatchGroup) {
                self.managedObjectContext.performAndWait {
                    do {
                        try DataAsset.dataAsset(data: data, dataMIMEType: downloadTask.response?.mimeType, url: originalRequestURL, context: self.managedObjectContext)

                        try self.managedObjectContext.save()
                    } catch {
                        self.logger.error("\(error as NSError, privacy: .public)")
                    }
                }
            }
        } catch {
            self.logger.error("\(error as NSError, privacy: .public)")
        }
    }
}
