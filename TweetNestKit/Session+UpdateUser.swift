//
//  Session+UpdateUser.swift
//  Session+UpdateUser
//
//  Created by Jaehong Kang on 2021/08/06.
//

import Foundation
import CoreData
import OrderedCollections
import UnifiedLogging
import Twitter
import SwiftUI

extension Session {
    public nonisolated func updateUsers<C>(ids userIDs: C, twitterSession: Twitter.Session, context _context: NSManagedObjectContext? = nil) async throws where C: Collection, C.Index == Int, C.Element == Twitter.User.ID {
        try await withExtendedBackgroundExecution {
            let context = _context ?? persistentContainer.newBackgroundContext()
            context.undoManager = _context?.undoManager
            
            let userIDs = OrderedSet(userIDs)

            try await withThrowingTaskGroup(of: (Date, [Twitter.User], Date).self) { chunkedUsersTaskGroup in
                for chunkedUserIDs in userIDs.chunked(into: 100) {
                    chunkedUsersTaskGroup.addTask {
                        let startDate = Date()
                        let users = try await [Twitter.User](ids: chunkedUserIDs, session: twitterSession)
                        let endDate = Date()

                        return (startDate, users, endDate)
                    }
                }

                try await withThrowingTaskGroup(of: Void.self) { taskGroup in
                    for try await chunkedUsers in chunkedUsersTaskGroup {
                        try Task.checkCancellation()
                        
                        for user in chunkedUsers.1 {
                            taskGroup.addTask {
                                try await context.perform(schedule: .enqueued) {
                                    try Task.checkCancellation()
                                    
                                    let userDetail = try UserDetail.createOrUpdate(
                                        twitterUser: user,
                                        userUpdateStartDate: chunkedUsers.0,
                                        userDetailCreationDate: chunkedUsers.2,
                                        context: context
                                    )

                                    if userDetail.user?.account != nil {
                                        // Don't update user data if user data has account. (Might overwrite followings/followers list)
                                        context.delete(userDetail)
                                    }

                                    if context.hasChanges {
                                        try context.save()
                                    }
                                }
                            }

                            taskGroup.addTask {
                                do {
                                    _ = try await DataAsset.dataAsset(for: user.profileImageOriginalURL, session: self, context: context)
                                } catch {
                                    Logger(subsystem: Bundle.module.bundleIdentifier!, category: "fetch-profile-image")
                                        .error("Error occurred while downloading image: \(String(reflecting: error), privacy: .public)")
                                }

                                try await context.perform(schedule: .enqueued) {
                                    try Task.checkCancellation()
                                    
                                    if context.hasChanges {
                                        try context.save()
                                    }
                                }
                            }
                        }
                    }

                    try await taskGroup.waitForAll()
                }
            }
        }
    }
}
