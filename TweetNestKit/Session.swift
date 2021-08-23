//
//  Session.swift
//  TweetNestKit
//
//  Created by Jaehong Kang on 2021/02/23.
//

import CoreData
import CloudKit
import AuthenticationServices
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

    public nonisolated let container: PersistentContainer
    private(set) nonisolated lazy var urlSession = URLSession(configuration: .twnk_default)
    private var twitterSessions = [URL: Twitter.Session]()

    public init(inMemory: Bool = false) {
        _twitterAPIConfiguration = .uninitialized { try await .iCloud }
        container = PersistentContainer(inMemory: inMemory)
    }

    public init(twitterAPIConfiguration: @autoclosure @escaping () async throws -> TwitterAPIConfiguration, inMemory: Bool = false) async {
        _twitterAPIConfiguration = .uninitialized { try await twitterAPIConfiguration() }
        container = PersistentContainer(inMemory: inMemory)
    }

    public init(twitterAPIConfiguration: TwitterAPIConfiguration, inMemory: Bool = false) {
        _twitterAPIConfiguration = .uninitialized { twitterAPIConfiguration }
        container = PersistentContainer(inMemory: inMemory)
    }
}

extension Session {
    public func twitterSession(for accountObjectID: NSManagedObjectID? = nil) async throws -> Twitter.Session {
        let twitterAPIConfiguration = try await twitterAPIConfiguration
        
        guard let accountObjectID = accountObjectID else {
            return Twitter.Session(consumerKey: twitterAPIConfiguration.apiKey, consumerSecret: twitterAPIConfiguration.apiKeySecret)
        }
        
        let twitterSession: Twitter.Session
        
        if let _twitterSession = twitterSessions[accountObjectID.uriRepresentation()] {
            twitterSession = _twitterSession
        } else {
            twitterSession = Twitter.Session(consumerKey: twitterAPIConfiguration.apiKey, consumerSecret: twitterAPIConfiguration.apiKeySecret)
            updateTwitterSession(twitterSession, for: accountObjectID)
        }

        try await twitterSession.updateCredential(credential(for: accountObjectID))

        return twitterSession
    }
    
    private func updateTwitterSession(_ twitterSession: Twitter.Session?, for accountObjectID: NSManagedObjectID) {
        guard accountObjectID.isTemporaryID == false else {
            return
        }
        
        twitterSessions[accountObjectID.uriRepresentation()] = twitterSession
    }
}

extension Session {
    nonisolated func download(from url: URL) async throws -> URL {
        let (url, response) = try await urlSession.download(from: url)
        guard
            let httpResponse = response as? HTTPURLResponse,
            (200..<300).contains(httpResponse.statusCode)
        else {
            throw SessionError.invalidServerResponse(response)
        }

        return url
    }
}

extension Session {
    public func authorizeNewAccount(
        webAuthenticationSessionHandler: @escaping (ASWebAuthenticationSession) -> Void
    ) async throws {
        let twitterSession = try await twitterSession()

        let requestToken = try await twitterSession.fetchRequestToken(callback: "tweet-nest://")

        let url: URL = try await withCheckedThrowingContinuation { continuation in
            webAuthenticationSessionHandler(
                ASWebAuthenticationSession(url: URL(twitterOAuthAuthorizeURLWithOAuthToken: requestToken.token), callbackURLScheme: "tweet-nest", completionHandler: { (url, error) in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: url!)
                    }
                })
            )
        }

        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)

        let token = urlComponents?.queryItems?.first(where: { $0.name == "oauth_token" })?.value ?? ""
        let verifier = urlComponents?.queryItems?.first(where: { $0.name == "oauth_verifier" })?.value ?? ""

        let accessToken = try await twitterSession.fetchAccessToken(token: token, verifier: verifier)

        await twitterSession.updateCredential(.init(accessToken))

        let twitterAccount = try await Twitter.Account.me(session: twitterSession)
        
        let accountObjectID = try await self.createNewAccount(tokenResponse: accessToken, twitterAccount: twitterAccount)
        
        updateTwitterSession(twitterSession, for: accountObjectID)
        
        try await updateAccount(accountObjectID)
    }

    private nonisolated func createNewAccount(tokenResponse: Twitter.Session.TokenResponse, twitterAccount: Twitter.Account) async throws -> NSManagedObjectID {
        let context = container.newBackgroundContext()

        return try await context.perform(schedule: .enqueued) {
            let account = Account(context: context)
            account.creationDate = Date()
            account.id = twitterAccount.id
            account.token = tokenResponse.token
            account.tokenSecret = tokenResponse.tokenSecret

            try context.save()

            return account.objectID
        }
    }
}

extension Session {
    private nonisolated func credential(for accountObjectID: NSManagedObjectID) async throws -> Twitter.Session.Credential? {
        let context = container.newBackgroundContext()
        
        return await context.perform(schedule: .enqueued) {
            guard
                let account = context.object(with: accountObjectID) as? Account,
                let token = account.token,
                let tokenSecret = account.tokenSecret
            else {
                return nil
            }

            return Twitter.Session.Credential(token: token, tokenSecret: tokenSecret)
        }
    }
}
