//
//  UserDataAssetsURLSessionManager.swift
//  TweetNestKit
//
//  Created by Jaehong Kang on 2022/04/19.
//

import Foundation
import BackgroundTask
import UnifiedLogging
import OrderedCollections
import CoreData
import CryptoKit

class UserDataAssetsURLSessionManager: NSObject {
    static let cacheExpirationTimeInterval: TimeInterval = 60 * 60 * 12

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

    private let dateFormatterForHTTPHeader: DateFormatter = .http

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
    private func latestUserDataAsset(for url: URL) throws -> ManagedUserDataAsset? {
        let dataAssetFetchRequest = ManagedUserDataAsset.fetchRequest()
        dataAssetFetchRequest.predicate = NSPredicate(format: "url == %@", url as NSURL)
        dataAssetFetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        dataAssetFetchRequest.propertiesToFetch = [
            (\ManagedUserDataAsset.dataMIMEType)._kvcKeyPathString!,
            (\ManagedUserDataAsset.dataSHA512Hash)._kvcKeyPathString!,
            (\ManagedUserDataAsset.lastFetchedDate)._kvcKeyPathString!,
            (\ManagedUserDataAsset.lastModifiedDate)._kvcKeyPathString!,
        ]
        dataAssetFetchRequest.returnsObjectsAsFaults = false
        dataAssetFetchRequest.fetchLimit = 1

        return try managedObjectContext.fetch(dataAssetFetchRequest).first
    }

    private func latestUserDataAssets(for urls: some Sequence<URL>) throws -> OrderedSet<ManagedUserDataAsset> {
        let dataAssetFetchRequest = ManagedUserDataAsset.fetchRequest()
        dataAssetFetchRequest.predicate = NSPredicate(format: "url IN %@", Array(urls))
        dataAssetFetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        dataAssetFetchRequest.propertiesToFetch = [
            (\ManagedUserDataAsset.dataMIMEType)._kvcKeyPathString!,
            (\ManagedUserDataAsset.dataSHA512Hash)._kvcKeyPathString!,
            (\ManagedUserDataAsset.lastFetchedDate)._kvcKeyPathString!,
            (\ManagedUserDataAsset.lastModifiedDate)._kvcKeyPathString!,
        ]
        dataAssetFetchRequest.returnsObjectsAsFaults = false

        return OrderedSet(
            try managedObjectContext.fetch(dataAssetFetchRequest)
                .lazy
                .uniqued(on: \.url)
        )
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
        let lastModifiedDates: [URL: Date]? = try? await managedObjectContext.perform(schedule: .immediate) {
            let latestUserDataAssets = try self.latestUserDataAssets(for: downloadRequests.lazy.compactMap { $0.urlRequest.url })

            return Dictionary(
                uniqueKeysWithValues: latestUserDataAssets
                    .compactMap {
                        guard
                            let url = $0.url,
                            let lastModifiedDate = $0.lastModifiedDate,
                            ($0.lastFetchedDate ?? .distantPast) > Date(timeIntervalSinceNow: -Self.cacheExpirationTimeInterval)
                        else {
                            return nil
                        }

                        return (url, lastModifiedDate)
                    }
            )
        }

        return await withCheckedContinuation { [urlSession] continuation in
            urlSession.getTasksWithCompletionHandler { [dateFormatterForHTTPHeader] _, _, downloadTasks in
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
                        urlRequest.setValue(
                            $0.urlRequest.url.flatMap { lastModifiedDates?[$0].flatMap { dateFormatterForHTTPHeader.string(from: $0) } },
                            forHTTPHeaderField: "If-Modified-Since"
                        )

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
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        guard let originalRequestURL = task.originalRequest?.url else {
            logger.error("originalRequest.url not found in \(task, privacy: .public)")
            return
        }

        guard let httpURLResponse = task.response as? HTTPURLResponse else {
            logger.error("response is not HTTPURLResponse in \(task, privacy: .public)")
            return
        }

        switch httpURLResponse.statusCode {
        case 200..<300:
            break
        case 304:
            logger.info("Cache hit for \(task, privacy: .public)")
            return
        default:
            logger.warning("Status code \(httpURLResponse.statusCode) found in \(task, privacy: .public)")
            return
        }

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
                        guard let latestUserDataAsset = try self.latestUserDataAsset(for: originalRequestURL) else {
                            return
                        }

                        latestUserDataAsset.lastFetchedDate = metrics.transactionMetrics.compactMap { $0.responseEndDate }.max()

                        dispatchGroup.notify(queue: dispatchQueue) {
                            self.saveManagedObjectContext()
                        }
                    }
                }
            } catch {
                logger.error("\(error as NSError, privacy: .public)")
            }
        }
    }
}

extension UserDataAssetsURLSessionManager: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let originalRequestURL = downloadTask.originalRequest?.url else {
            logger.error("originalRequest.url not found in \(downloadTask, privacy: .public)")
            return
        }

        guard let httpURLResponse = downloadTask.response as? HTTPURLResponse else {
            logger.error("response is not HTTPURLResponse in \(downloadTask, privacy: .public)")
            return
        }

        switch httpURLResponse.statusCode {
        case 200..<300:
            break
        case 304:
            logger.info("Cache hit for \(downloadTask, privacy: .public)")
            return
        default:
            logger.warning("Status code \(httpURLResponse.statusCode) found in \(downloadTask, privacy: .public)")
            return
        }

        do {
            let data = try Data(contentsOf: location, options: .mappedIfSafe)

            dispatchGroup.enter()
            Task.detached { [dispatchGroup, dispatchQueue, managedObjectContext, logger, dateFormatterForHTTPHeader] in
                defer {
                    dispatchGroup.leave()
                }

                while managedObjectContext.persistentStoreCoordinator?.persistentStores.isEmpty != false {
                    await Task.yield()
                }

                let dataSHA512Hash = Data(SHA512.hash(data: data))
                let dataMIMEType = downloadTask.response?.mimeType
                let lastModifiedDate = (downloadTask.response as? HTTPURLResponse)
                    .flatMap {
                        $0.value(forHTTPHeaderField: "Last-Modified")
                    }
                    .flatMap {
                        dateFormatterForHTTPHeader.date(from: $0)
                    }

                do {
                    try await withExtendedBackgroundExecution {
                        try await managedObjectContext.perform(schedule: .enqueued) {
                            let lastestDataAsset = try self.latestUserDataAsset(for: originalRequestURL)

                            if
                                let lastestDataAsset = lastestDataAsset,
                                lastestDataAsset.dataSHA512Hash == dataSHA512Hash
                            {
                                if
                                    let dataMIMEType = dataMIMEType,
                                    lastestDataAsset.dataMIMEType != dataMIMEType
                                {
                                    lastestDataAsset.dataMIMEType = dataMIMEType
                                }

                                if
                                    let lastModifiedDate = lastModifiedDate,
                                    lastestDataAsset.lastModifiedDate != lastModifiedDate
                                {
                                    lastestDataAsset.lastModifiedDate = lastModifiedDate
                                }
                            } else {
                                let newDataAsset = ManagedUserDataAsset(context: managedObjectContext)
                                newDataAsset.data = data
                                newDataAsset.dataSHA512Hash = dataSHA512Hash
                                newDataAsset.dataMIMEType = dataMIMEType
                                newDataAsset.url = originalRequestURL
                                newDataAsset.lastModifiedDate = lastModifiedDate
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
