//
//  Session.swift
//  TweetNestKit
//
//  Created by Jaehong Kang on 2021/02/23.
//

import CoreData
import CloudKit
import OrderedCollections
import Twitter

public actor Session {
    public static let shared = Session()

    static let cloudKitIdentifier = "iCloud.\(Bundle.module.bundleIdentifier!)"
    static let applicationGroupIdentifier = "group.\(Bundle.module.bundleIdentifier!)"

    private var _twitterAPIConfiguration: AsyncLazy<TwitterAPIConfiguration>
    public var twitterAPIConfiguration: TwitterAPIConfiguration {
        get async throws {
            switch _twitterAPIConfiguration {
            case .uninitialized(let initializer):
                let value = try await initializer()
                _twitterAPIConfiguration = .initialized(value)
                return value
            case .initialized(let value):
                return value
            }
        }
    }
    
    private(set) nonisolated lazy var urlSession = URLSession(configuration: .twnk_default)

    public nonisolated let persistentContainer: PersistentContainer
    
    private nonisolated lazy var persistentStoreRemoteChangeNotification = NotificationCenter.default
        .publisher(for: .NSPersistentStoreRemoteChange, object: persistentContainer.persistentStoreCoordinator)
        .sink { [weak self] _ in
            self?.handlePersistentStoreRemoteChanges()
        }
    
    private(set) var twitterSessions = [URL: Twitter.Session]()
    
    private init(twitterAPIConfiguration: @escaping () async throws -> TwitterAPIConfiguration, inMemory: Bool = false) {
        _twitterAPIConfiguration = .uninitialized { try await twitterAPIConfiguration() }
        persistentContainer = PersistentContainer(inMemory: inMemory)
    }
}

extension Session {
    public convenience init(inMemory: Bool = false) {
        self.init(twitterAPIConfiguration: { try await .iCloud }, inMemory: inMemory)
        
        _ = persistentStoreRemoteChangeNotification
    }

    public convenience init(twitterAPIConfiguration: @autoclosure @escaping () async throws -> TwitterAPIConfiguration, inMemory: Bool = false) async {
        self.init(twitterAPIConfiguration: { try await twitterAPIConfiguration() }, inMemory: inMemory)
        
        _ = persistentStoreRemoteChangeNotification
    }

    public convenience init(twitterAPIConfiguration: TwitterAPIConfiguration, inMemory: Bool = false) {
        self.init(twitterAPIConfiguration: { twitterAPIConfiguration }, inMemory: inMemory)
        
        _ = persistentStoreRemoteChangeNotification
    }
}

extension Session {
    public func twitterSession(for accountObjectID: NSManagedObjectID? = nil) async throws -> Twitter.Session {
        let twitterAPIConfiguration = try await twitterAPIConfiguration
        
        guard let accountObjectID = accountObjectID, accountObjectID.isTemporaryID == false else {
            return Twitter.Session(consumerKey: twitterAPIConfiguration.apiKey, consumerSecret: twitterAPIConfiguration.apiKeySecret)
        }
        
        guard let twitterSession: Twitter.Session = twitterSessions[accountObjectID.uriRepresentation()] else {
            let twitterSession = Twitter.Session(twitterAPIConfiguration: twitterAPIConfiguration)
            updateTwitterSession(twitterSession, for: accountObjectID)
            
            try await twitterSession.updateCredential(credential(for: accountObjectID))
            
            return twitterSession
        }
        
        return twitterSession
    }
    
    func updateTwitterSession(_ twitterSession: Twitter.Session?, for accountObjectID: NSManagedObjectID) {
        guard accountObjectID.isTemporaryID == false else {
            return
        }
        
        twitterSessions[accountObjectID.uriRepresentation()] = twitterSession
    }
}
