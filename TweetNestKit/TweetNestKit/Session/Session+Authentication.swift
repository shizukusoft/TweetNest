//
//  Session+Authentication.swift
//  TweetNestKit
//
//  Created by 강재홍 on 2022/08/19.
//

import Foundation
import AuthenticationServices
import CoreData
import Twitter
import TwitterV1

extension Session {
    public enum AccountAuthenticateError: Error {
        case unknown
        case userIDNotFound
        case userIDMismatch
    }

    public func authenticateAccount(
        managedAccountObjectID _managedAccountObjectID: NSManagedObjectID? = nil,
        webAuthenticationSessionHandler: @escaping (ASWebAuthenticationSession) -> Void
    ) async throws {
        let ephemeralTwitterSession = try await twitterSession()
        let managedObjectContext = persistentContainer.newBackgroundContext()

        let requestToken = try await ephemeralTwitterSession.fetchRequestToken(callback: "tweet-nest://")

        let url: URL = try await webAuthenticate(
            oAuthToken: requestToken.token,
            webAuthenticationSessionHandler: webAuthenticationSessionHandler
        )

        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)

        let token = urlComponents?.queryItems?.first(where: { $0.name == "oauth_token" })?.value ?? ""
        let verifier = urlComponents?.queryItems?.first(where: { $0.name == "oauth_verifier" })?.value ?? ""

        let accessToken = try await ephemeralTwitterSession.fetchAccessToken(token: token, verifier: verifier)
        await ephemeralTwitterSession.updateCredential(.init(accessToken))

        async let accountUser = TwitterV1.User.me(session: ephemeralTwitterSession)

        let managedAccountObjectID: NSManagedObjectID
        if let _managedAccountObjectID = _managedAccountObjectID {
            guard let accountUserID = await userID(for: _managedAccountObjectID, managedObjectContext: managedObjectContext) else {
                throw AccountAuthenticateError.userIDNotFound
            }

            guard accountUserID == String(try await accountUser.id) else {
                throw AccountAuthenticateError.userIDMismatch
            }

            try await managedObjectContext.perform(schedule: .immediate) {
                guard let managedAccount = managedObjectContext.object(with: _managedAccountObjectID) as? ManagedAccount else {
                    throw AccountAuthenticateError.unknown
                }

                managedAccount.token = accessToken.token
                managedAccount.tokenSecret = accessToken.tokenSecret

                try managedObjectContext.save()
            }

            managedAccountObjectID = _managedAccountObjectID
        } else {
            let accountUserID = try await String(accountUser.id)

            managedAccountObjectID = try await managedObjectContext.perform(schedule: .immediate) { [self] in
                let account = try account(for: accountUserID, managedObjectContext: managedObjectContext) ?? ManagedAccount(context: managedObjectContext)

                account.token = accessToken.token
                account.tokenSecret = accessToken.tokenSecret

                if account.userID == nil {
                    account.userID = accountUserID
                }

                try managedObjectContext.save()

                return account.objectID
            }
        }

        Task.detached(priority: .utility) { [self] in
            do {
                try await updateUsers(for: [managedAccountObjectID])
                    .forEach {
                        _ = try $0.value.get()
                    }
            } catch {
                logger.error("Error occurred while update account \(managedAccountObjectID, privacy: .public): \(error as NSError, privacy: .public)")

                try await postUserNotification(error: error, accountObjectID: managedAccountObjectID)
            }
        }
    }

    private func userID(for managedAccountObjectID: NSManagedObjectID, managedObjectContext: NSManagedObjectContext) async -> Twitter.User.ID? {
        await managedObjectContext.perform(schedule: .immediate) {
            guard let managedAccount = managedObjectContext.object(with: managedAccountObjectID) as? ManagedAccount else {
                return nil
            }

            return managedAccount.userID
        }
    }

    private func account(for userID: Twitter.User.ID, managedObjectContext: NSManagedObjectContext) throws -> ManagedAccount? {
        let fetchRequest = ManagedAccount.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userID == %@", userID)
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \ManagedAccount.creationDate, ascending: false),
            NSSortDescriptor(keyPath: \ManagedAccount.modificationDate, ascending: false)
        ]
        fetchRequest.propertiesToFetch = [
            (\ManagedAccount.token)._kvcKeyPathString!,
            (\ManagedAccount.tokenSecret)._kvcKeyPathString!,
            (\ManagedAccount.userID)._kvcKeyPathString!
        ]
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.fetchLimit = 1

        return try managedObjectContext.fetch(fetchRequest).first
    }

    private func webAuthenticate(oAuthToken: String, webAuthenticationSessionHandler: @escaping (ASWebAuthenticationSession) -> Void) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            webAuthenticationSessionHandler(
                ASWebAuthenticationSession(
                    url: URL(twitterOAuthAuthorizeURLWithOAuthToken: oAuthToken),
                    callbackURLScheme: "tweet-nest",
                    completionHandler: { (url, error) in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume(returning: url!)
                        }
                    }
                )
            )
        }
    }
}
