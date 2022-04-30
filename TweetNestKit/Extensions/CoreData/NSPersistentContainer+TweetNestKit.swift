//
//  NSPersistentContainer+TweetNestKit.swift
//  TweetNestKit
//
//  Created by 강재홍 on 2022/04/30.
//

import CoreData

extension NSPersistentContainer {
    public struct LoadingError: Error {
        public var errors: [NSPersistentStoreDescription: Error]
    }

    public func loadPersistentStores(completionHandler block: @escaping (Result<Void, LoadingError>) -> Void) {
        var loadedPersistentStores = [NSPersistentStoreDescription: Error?]()

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
