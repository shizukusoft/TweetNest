//
//  UserDataAssetsURLSessionManager.swift
//  TweetNestKit
//
//  Created by 강재홍 on 2022/04/19.
//

import Foundation
import BackgroundTask
import UnifiedLogging
import OrderedCollections
import CoreData

class UserDataAssetsURLSessionManager: NSObject {
    static let backgroundURLSessionIdentifier = Bundle.tweetNestKit.bundleIdentifier! + ".user-data-assets"

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

        if session.isShared {
            urlSessionConfiguration = .twnk_background(withIdentifier: Self.backgroundURLSessionIdentifier)
        } else {
            urlSessionConfiguration = .twnk_default
        }

        urlSessionConfiguration.httpAdditionalHeaders = nil
        urlSessionConfiguration.sessionSendsLaunchEvents = true
        urlSessionConfiguration.allowsConstrainedNetworkAccess = false

        return urlSessionConfiguration
    }

    private unowned let session: Session

    private let dispatchGroup = DispatchGroup()
    private lazy var dispatchQueue = DispatchQueue(label: String(reflecting: self), qos: .default, attributes: [.concurrent], autoreleaseFrequency: .workItem)
    private lazy var operationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.underlyingQueue = dispatchQueue

        return operationQueue
    }()
    private lazy var memoryPressureSource = DispatchSource.makeMemoryPressureSource(eventMask: .all, queue: dispatchQueue)

    private let logger = Logger(label: Bundle.tweetNestKit.bundleIdentifier!, category: String(reflecting: UserDataAssetsURLSessionManager.self))

    private lazy var urlSession = URLSession(configuration: urlSessionConfiguration, delegate: self, delegateQueue: operationQueue)

    private lazy var managedObjectContext = session.persistentContainer.newBackgroundContext()

    init(session: Session) {
        self.session = session

        super.init()

        _ = urlSession

        memoryPressureSource.setEventHandler(flags: [.barrier]) { [weak self] in
            self?.didReceveMemoryPressure()
        }

        memoryPressureSource.activate()
    }

    deinit {
        invalidate()
    }
}

extension UserDataAssetsURLSessionManager {
    func invalidate() {
        urlSession.invalidateAndCancel()
        memoryPressureSource.cancel()
    }
}

extension UserDataAssetsURLSessionManager {
    private func saveManagedObjectContext() {
        Task { [managedObjectContext] in
            do {
                try await withExtendedBackgroundExecution {
                    try await managedObjectContext.perform {
                        guard managedObjectContext.hasChanges else {
                            return
                        }

                        try managedObjectContext.save()
                    }
                }
            } catch {
                logger.error("\(error as NSError, privacy: .public)")
            }
        }
    }
}

extension UserDataAssetsURLSessionManager {
    private func didReceveMemoryPressure() {
        saveManagedObjectContext()
    }
}

extension UserDataAssetsURLSessionManager {
    @MainActor
    func handleBackgroundURLSessionEvents(completionHandler: @escaping () -> Void) {
        _backgroundURLSessionEventsCompletionHandler = completionHandler
    }
}

extension UserDataAssetsURLSessionManager {
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

                let newDownloadTasks: [URLSessionDownloadTask] = downloadRequests.lazy
                    .uniqued()
                    .compactMap {
                        var urlRequest = $0.urlRequest
                        urlRequest.allowsExpensiveNetworkAccess = TweetNestKitUserDefaults.standard.downloadsDataAssetsUsingExpensiveNetworkAccess

                        guard (pendingDownloadTasks[urlRequest]?.count ?? 0) < 1 else {
                            return nil
                        }

                        let downloadTask = urlSession.downloadTask(with: urlRequest)
                        downloadTask.countOfBytesClientExpectsToSend = 1024
                        downloadTask.countOfBytesClientExpectsToReceive = $0.expectsToReceiveFileSize
                        downloadTask.priority = $0.priority

                        return downloadTask
                    }

                newDownloadTasks.forEach {
                    $0.resume()
                }

                continuation.resume()
            }
        }
    }
}

extension UserDataAssetsURLSessionManager: URLSessionDelegate {
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        dispatchGroup.notify(queue: dispatchQueue) {
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

extension UserDataAssetsURLSessionManager: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            logger.error("\(error as NSError, privacy: .public)")
        }
    }
}

extension UserDataAssetsURLSessionManager: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let originalRequestURL = downloadTask.originalRequest?.url else { return }

        do {
            let data = try Data(contentsOf: location, options: .mappedIfSafe)
            let creationDate = Date()

            dispatchGroup.enter()
            Task.detached { [dispatchGroup, dispatchQueue, managedObjectContext, logger] in
                defer {
                    dispatchGroup.leave()
                }

                while managedObjectContext.persistentStoreCoordinator?.persistentStores.isEmpty != false {
                    await Task.yield()
                }

                do {
                    try await withExtendedBackgroundExecution {
                        try await managedObjectContext.perform(schedule: .enqueued) {
                            try ManagedUserDataAsset.userDataAsset(
                                data: data,
                                dataMIMEType: downloadTask.response?.mimeType,
                                url: originalRequestURL,
                                creationDate: creationDate,
                                context: managedObjectContext
                            )

                            guard managedObjectContext.hasChanges else {
                                return
                            }

                            dispatchGroup.notify(queue: dispatchQueue) {
                                self.saveManagedObjectContext()
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
