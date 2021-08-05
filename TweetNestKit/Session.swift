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

    static let moduleName = "TweetNestKit"
    static let moduleIdentifier = "app.tweetnest.\(moduleName)"
    static let cloudKitIdentifier = "iCloud.\(moduleIdentifier)"
    static let applicationGroupIdentifier = "group.\(moduleIdentifier)"

    private let twitterAPIConfigurationTask: Task<TwitterAPIConfiguration, Error>
    public var twitterAPIConfiguration: TwitterAPIConfiguration {
        get async throws {
            try await twitterAPIConfigurationTask.value
        }
    }

    private var twitterSessions = [Twitter.Account.ID: Twitter.Session]()
    public nonisolated let container: PersistentContainer

    public init(inMemory: Bool = false) {
        self.twitterAPIConfigurationTask = Task.detached {
            try await .iCloud
        }
        container = PersistentContainer(inMemory: inMemory)
    }

    public init(twitterAPIConfiguration: @autoclosure @escaping () async throws -> TwitterAPIConfiguration, inMemory: Bool = false) async {
        self.twitterAPIConfigurationTask = Task.detached {
            try await twitterAPIConfiguration()
        }
        container = PersistentContainer(inMemory: inMemory)
    }

    public init(twitterAPIConfiguration: TwitterAPIConfiguration, inMemory: Bool = false) {
        self.twitterAPIConfigurationTask = Task.detached {
            twitterAPIConfiguration
        }
        container = PersistentContainer(inMemory: inMemory)
    }
}

extension Session {
    func twitterSession(for accountID: Twitter.Account.ID? = nil) async throws -> Twitter.Session {
        if let accountID = accountID, let session = twitterSessions[accountID] {
            return session
        }

        let twitterAPIConfiguration = try await twitterAPIConfiguration

        let twitterSession = await Twitter.Session(consumerKey: twitterAPIConfiguration.apiKey, consumerSecret: twitterAPIConfiguration.apiKeySecret)
        guard let accountID = accountID else {
            return twitterSession
        }

        let credential = try await credential(for: accountID)
        guard let credential = credential else {
            return twitterSession
        }

        await twitterSession.updateCredential(credential)

        twitterSessions[accountID] = twitterSession

        return twitterSession
    }

    func destroyTwitterSession(for accountID: Twitter.Account.ID) {
        twitterSessions[accountID] = nil
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
                ASWebAuthenticationSession(url: URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")!, callbackURLScheme: "tweet-nest", completionHandler: { (url, error) in
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

        let account = try await Twitter.Account.me(session: twitterSession)

        self.twitterSessions[account.id] = twitterSession
        try await self.createNewAccount(tokenResponse: accessToken, twitterAccount: account)
    }

    private func createNewAccount(tokenResponse: Twitter.Session.TokenResponse, twitterAccount: Twitter.Account) async throws {
        let context = container.newBackgroundContext()

        let accountObjectID: NSManagedObjectID = try await context.perform {
            let account = Account(context: context)
            account.creationDate = Date()
            account.id = twitterAccount.id
            account.token = tokenResponse.token
            account.tokenSecret = tokenResponse.tokenSecret

            try context.save()

            return account.objectID
        }

        try await updateAccount(accountObjectID)
    }
}

extension Session {
    private func credential(for accountID: Twitter.Account.ID) async throws -> Twitter.Session.Credential? {
        try await container.performBackgroundTask { (context) in
            let accountFetchRequest: NSFetchRequest<Account> = Account.fetchRequest()
            accountFetchRequest.predicate = NSPredicate(format: "id == %ld", accountID)
            accountFetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

            guard
                let account = try context.fetch(accountFetchRequest).first,
                let token = account.token,
                let tokenSecret = account.tokenSecret
            else {
                return nil
            }

            return Twitter.Session.Credential(token: token, tokenSecret: tokenSecret)
        }
    }
}
