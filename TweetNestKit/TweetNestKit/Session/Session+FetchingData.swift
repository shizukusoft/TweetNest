//
//  Session+FetchingData.swift
//  TweetNestKit
//
//  Created by Jaehong Kang on 2022/10/21.
//

import Foundation
import CoreData
import UserNotifications
import UnifiedLogging
import BackgroundTask

extension Session {
    private func errorNotificationRequest(_ error: Error, for accountObjectID: NSManagedObjectID? = nil) -> UNNotificationRequest {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = String(localized: "Fetch New Data Error", bundle: .tweetNestKit, comment: "fetch-new-data-error notification title.")
        notificationContent.interruptionLevel = .active
        notificationContent.sound = .default

        if
            let localizedError = error as? LocalizedError,
            let errorDescription = localizedError.errorDescription,
            let failureReason = localizedError.failureReason
        {
            notificationContent.subtitle = errorDescription
            notificationContent.body = failureReason
        } else {
            notificationContent.body = error.localizedDescription
        }

        if let accountObjectID = accountObjectID {
            let context = persistentContainer.newBackgroundContext()

            let persistentID: UUID? = context.performAndWait {
                (context.object(with: accountObjectID) as? ManagedAccount)?.persistentID
            }

            notificationContent.threadIdentifier = persistentID?.uuidString ?? accountObjectID.uriRepresentation().absoluteString
        }

        return UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: nil)
    }

    func postUserNotification(error: Error, accountObjectID: NSManagedObjectID? = nil) async throws {
        switch error {
        case let error as CancellableError where error.isCancelled:
            break
        case is ProcessInfo.TaskAssertionError:
            break
        default:
            let notificationContent = UNMutableNotificationContent()
            notificationContent.title = String(localized: "Fetch New Data Error", bundle: .tweetNestKit, comment: "fetch-new-data-error notification title.")
            notificationContent.interruptionLevel = .active
            notificationContent.sound = .default

            if
                let localizedError = error as? LocalizedError,
                let errorDescription = localizedError.errorDescription,
                let failureReason = localizedError.failureReason
            {
                notificationContent.subtitle = errorDescription
                notificationContent.body = failureReason
            } else {
                notificationContent.body = error.localizedDescription
            }

            if let accountObjectID = accountObjectID {
                let context = persistentContainer.newBackgroundContext()

                let persistentID: UUID? = context.performAndWait {
                    (context.object(with: accountObjectID) as? ManagedAccount)?.persistentID
                }

                notificationContent.threadIdentifier = persistentID?.uuidString ?? accountObjectID.uriRepresentation().absoluteString
            }

            let request = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: nil)
            try await UNUserNotificationCenter.current().add(request)
        }
    }

    @discardableResult
    public func fetchNewData(force: Bool = false) async throws -> Bool {
        guard
            force || TweetNestKitUserDefaults.standard.lastFetchNewDataDate.addingTimeInterval(TweetNestKitUserDefaults.standard.fetchNewDataInterval) < Date()
        else {
            return false
        }

        TweetNestKitUserDefaults.standard.lastFetchNewDataDate = Date()

        let logger = Logger(subsystem: Bundle.tweetNestKit.bundleIdentifier!, category: "fetch-new-data")

        do {
            var hasChanges = false

            for result in try await updateAllUsers() {
                let accountObjectID = result.0

                do {
                    hasChanges = try hasChanges || result.value.map { $0.oldUserDetailObjectID != $0.newUserDetailObjectID }.get()
                } catch {
                    logger.error("Error occurred while update account \(accountObjectID, privacy: .public): \(error as NSError, privacy: .public)")

                    try await postUserNotification(error: error, accountObjectID: accountObjectID)
                }
            }

            return hasChanges
        } catch {
            logger.error("Error occurred while update accounts: \(error as NSError, privacy: .public)")

            try await postUserNotification(error: error)

            return false
        }
    }
}
