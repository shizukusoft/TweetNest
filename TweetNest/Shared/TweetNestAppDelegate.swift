//
//  TweetNestAppDelegate.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/03/22.
//

import Foundation
import UserNotifications
import TweetNestKit
import UnifiedLogging

@MainActor
class TweetNestAppDelegate: NSObject, ObservableObject {
    #if DEBUG
    var session: Session {
        if TweetNestApp.isPreview {
            return Session.preview
        } else {
            return Session.shared
        }
    }
    #else
    let session = Session.shared
    #endif

    @Published private(set) var sessionPersistentContainerStoresLoadingResult: Result<Void, Swift.Error>?

    override init() {
        super.init()

        Task(priority: .utility) { [self] in
            await loadSessionPersistentContainerStores()

            do {
                try await session.backgroundTaskScheduler.scheduleBackgroundTasks(for: .active)

            } catch {
                Logger().error("Error occurred while schedule refresh: \(error as NSError, privacy: .public)")
            }
        }
    }

    func loadSessionPersistentContainerStores() async {
        do {
            try await session.persistentContainer.loadPersistentStores()

            #if DEBUG
            if TweetNestApp.isPreview {
                try insertPreviewDataToPersistentContainer()
            }
            #endif

            sessionPersistentContainerStoresLoadingResult = .success(Void())
        } catch {
            Logger().error("Error occurred while load persistent stores: \(error as NSError, privacy: .public)")
            sessionPersistentContainerStoresLoadingResult = .failure(error)
        }
    }
}

extension TweetNestAppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.badge, .sound, .list, .banner]
    }
}
