//
//  Session+NewAccount.swift
//  Session+NewAccount
//
//  Created by Jaehong Kang on 2021/08/30.
//

import Foundation
import AuthenticationServices
import CoreData
import Twitter

extension Session {
    public nonisolated func authorizeNewAccount(
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

        await updateTwitterSession(twitterSession, for: accountObjectID)

        try await updateAccount(accountObjectID)
    }

    private nonisolated func createNewAccount(tokenResponse: Twitter.Session.TokenResponse, twitterAccount: Twitter.Account) async throws -> NSManagedObjectID {
        let context = persistentContainer.newBackgroundContext()

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
