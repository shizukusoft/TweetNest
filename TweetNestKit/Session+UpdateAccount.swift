//
//  Session+UpdateAccount.swift
//  TweetNestKit
//
//  Created by Jaehong Kang on 2021/08/03.
//

import Foundation
import CoreData
import Twitter

extension Session {
    @discardableResult
    public func updateAccount(_ accountObjectID: NSManagedObjectID) async throws -> Bool {
        let context = container.newBackgroundContext()

        let accountID = await context.perform {
            (context.object(with: accountObjectID) as? Account)?.id
        }

        guard let accountID = accountID else {
            throw SessionError.unknown
        }

        let twitterSession = try await twitterSession(for: accountID)

        let updateResult = try await updateUser(id: String(accountID), with: twitterSession)

        await context.perform {
            let user = context.object(with: updateResult.userObjectID) as? User
            let account = context.object(with: accountObjectID) as? Account

            user?.account = account
        }

        return updateResult.hasChanges
    }
}

extension Session {
    private static func urlData(from url: URL) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard
            let httpResponse = response as? HTTPURLResponse,
            (200..<300).contains(httpResponse.statusCode)
        else {
            throw SessionError.invalidServerResponse
        }

        return data
    }
}
