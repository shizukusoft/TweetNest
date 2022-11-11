//
//  NSPersistentContainer+TweetNestKit.swift
//  TweetNestKit
//
//  Created by 강재홍 on 2022/04/30.
//

import CoreData
import Algorithms
import OrderedCollections

extension NSPersistentContainer {
    public struct LoadingError: Error {
        public var errors: OrderedDictionary<NSPersistentStoreDescription, Error>
    }

    public func loadPersistentStores(completionHandler block: @escaping (Result<Void, LoadingError>) -> Void) {
        var loadedPersistentStores = OrderedDictionary<NSPersistentStoreDescription, Error?>()

        self.loadPersistentStores { (storeDescription, error) in
            loadedPersistentStores[storeDescription] = error

            if loadedPersistentStores.count == self.persistentStoreDescriptions.count {
                let errors = loadedPersistentStores.compactMapValues { $0 }

                guard errors.isEmpty else {
                    block(.failure(LoadingError(errors: errors)))
                    return
                }

                block(.success(()))
            }
        }
    }

    public func loadPersistentStores() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            self.loadPersistentStores { result in
                continuation.resume(with: result)
            }
        }
    }
}

extension NSPersistentContainer.LoadingError: LocalizedError {
    public var errorDescription: String? {
        errors.values
            .lazy
            .map { ($0 as? LocalizedError)?.errorDescription ?? $0.localizedDescription }
            .uniqued()
            .joined(separator: "\n")
    }

    public var failureReason: String? {
        errors.values
            .lazy
            .compactMap { ($0 as? LocalizedError)?.failureReason ?? ($0 as NSError).localizedFailureReason }
            .uniqued()
            .joined(separator: "\n")
    }

    public var recoverySuggestion: String? {
        errors.values
            .lazy
            .compactMap { ($0 as? LocalizedError)?.recoverySuggestion ?? ($0 as NSError).localizedRecoverySuggestion }
            .uniqued()
            .joined(separator: "\n")
    }
}
