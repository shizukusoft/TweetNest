//
//  Session+Credential.swift
//  Session+Credential
//
//  Created by Jaehong Kang on 2021/08/30.
//

import Foundation
import CoreData
import Twitter

extension Session {
    func credential(for accountObjectID: NSManagedObjectID) async throws -> Twitter.Session.Credential? {
        let context = persistentContainer.newBackgroundContext()

        return await context.perform(schedule: .enqueued) {
            guard
                let account = try? context.existingObject(with: accountObjectID) as? Account
            else {
                return nil
            }

            return account.credential
        }
    }
}
