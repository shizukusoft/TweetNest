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
#if canImport(UIKit)
import UIKit
#endif

@MainActor
class TweetNestAppDelegate: NSObject, ObservableObject {
    #if DEBUG
    let session: Session = {
        if CommandLine.arguments.contains("-com.tweetnest.TweetNest.Preview") {
            return Session.preview
        } else {
            return Session.shared
        }
    }()
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
            if CommandLine.arguments.contains("-com.tweetnest.TweetNest.Preview") {
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

#if DEBUG
extension TweetNestAppDelegate {
    private func insertPreviewDataToPersistentContainer() throws {
        let viewContext = self.session.persistentContainer.viewContext

        let now = Date()

        let tweetnestAccount = Account(context: viewContext)
        tweetnestAccount.creationDate = Date(timeIntervalSince1970: 1628780400)
        tweetnestAccount.userID = "1352231658661920770"
        tweetnestAccount.preferences.fetchBlockingUsers = true

        let tweetnestUser = User(context: viewContext)
        tweetnestUser.creationDate = Date(timeIntervalSince1970: 1628780400)
        tweetnestUser.lastUpdateStartDate = now
        tweetnestUser.lastUpdateEndDate = now
        tweetnestUser.modificationDate = now
        tweetnestUser.id = "1352231658661920770"

        let tweetnestUserDetail1 = UserDetail(context: viewContext)
        tweetnestUserDetail1.creationDate = Date(timeIntervalSince1970: 1628780400)
        tweetnestUserDetail1.followerUserIDs = ["783214", "17874544"]
        tweetnestUserDetail1.followerUsersCount = 2
        tweetnestUserDetail1.followingUserIDs = ["783214", "17874544"]
        tweetnestUserDetail1.followingUsersCount = 2
        tweetnestUserDetail1.userCreationDate = Date(timeIntervalSince1970: 1616357217)
        tweetnestUserDetail1.location = "대한민국 서울"
        tweetnestUserDetail1.name = "TweetNest"
        tweetnestUserDetail1.username = "TweetNest_App"
        tweetnestUserDetail1.profileImageURL = URL(string: "https://pbs.twimg.com/profile_images/1373878674903113729/JL3SGoch.png")
        tweetnestUserDetail1.url = URL(string: "https://www.tweetnest.com")
        tweetnestUserDetail1.user = tweetnestUser

        let tweetnestUserDetail2 = UserDetail(context: viewContext)
        tweetnestUserDetail2.creationDate = Date(timeIntervalSince1970: 1631709579)
        tweetnestUserDetail2.followerUserIDs = ["783214"]
        tweetnestUserDetail2.followerUsersCount = 1
        tweetnestUserDetail2.followingUserIDs = ["783214"]
        tweetnestUserDetail2.followingUsersCount = 1
        tweetnestUserDetail2.userCreationDate = Date(timeIntervalSince1970: 1616357217)
        tweetnestUserDetail2.location = "대한민국 서울"
        tweetnestUserDetail2.name = "TweetNest"
        tweetnestUserDetail2.username = "TweetNest_App"
        tweetnestUserDetail2.profileImageURL = URL(string: "https://pbs.twimg.com/profile_images/1373878674903113729/JL3SGoch.png")
        tweetnestUserDetail2.url = URL(string: "https://www.tweetnest.com")
        tweetnestUserDetail2.user = tweetnestUser

        let tweetnestUserDetail3 = UserDetail(context: viewContext)
        tweetnestUserDetail3.creationDate = now
        tweetnestUserDetail3.followerUserIDs = ["783214", "380749300"]
        tweetnestUserDetail3.followerUsersCount = 2
        tweetnestUserDetail3.followingUserIDs = ["783214", "380749300"]
        tweetnestUserDetail3.followingUsersCount = 2
        tweetnestUserDetail3.userCreationDate = Date(timeIntervalSince1970: 1616357217)
        tweetnestUserDetail3.location = "대한민국 서울"
        tweetnestUserDetail3.name = "TweetNest"
        tweetnestUserDetail3.username = "TweetNest_App"
        tweetnestUserDetail3.profileImageURL = URL(string: "https://pbs.twimg.com/profile_images/1373878674903113729/JL3SGoch.png")
        tweetnestUserDetail3.url = URL(string: "https://www.tweetnest.com")
        tweetnestUserDetail3.user = tweetnestUser

        let tweetnestProfileImageDataAsset = DataAsset(context: viewContext)
        tweetnestProfileImageDataAsset.url = tweetnestUserDetail1.profileImageURL
        tweetnestProfileImageDataAsset.data = NSDataAsset(name: "TweetNestProfileImageData")?.data

        let twitterUser = User(context: viewContext)
        twitterUser.creationDate = now
        twitterUser.lastUpdateStartDate = now
        twitterUser.lastUpdateEndDate = now
        twitterUser.modificationDate = now
        twitterUser.id = "783214"

        let twitterUserDetail = UserDetail(context: viewContext)
        twitterUserDetail.creationDate = now
        twitterUserDetail.followerUsersCount = 0
        twitterUserDetail.followingUsersCount = 0
        twitterUserDetail.userCreationDate = Date(timeIntervalSinceReferenceDate: 1171982154)
        twitterUserDetail.location = "everywhere"
        twitterUserDetail.name = "Twitter"
        twitterUserDetail.username = "Twitter"
        twitterUserDetail.profileImageURL = URL(string: "https://pbs.twimg.com/profile_images/1354479643882004483/Btnfm47p.jpg")
        twitterUserDetail.url = URL(string: "https://about.twitter.com/")
        twitterUserDetail.user = twitterUser
        twitterUserDetail.userAttributedDescription = NSAttributedString(string: "what’s happening?!")

        let twitterSupportUser = User(context: viewContext)
        twitterSupportUser.creationDate = now
        twitterSupportUser.lastUpdateStartDate = now
        twitterSupportUser.lastUpdateEndDate = now
        twitterSupportUser.modificationDate = now
        twitterSupportUser.id = "17874544"

        let twitterSupportUserDetail = UserDetail(context: viewContext)
        twitterSupportUserDetail.creationDate = now
        twitterSupportUserDetail.followerUsersCount = 0
        twitterSupportUserDetail.followingUsersCount = 0
        twitterSupportUserDetail.userCreationDate = Date(timeIntervalSinceReferenceDate: 1228416717)
        twitterSupportUserDetail.location = "Twitter HQ"
        twitterSupportUserDetail.name = "Twitter Support"
        twitterSupportUserDetail.username = "TwitterSupport"
        twitterSupportUserDetail.profileImageURL = URL(string: "https://pbs.twimg.com/profile_images/1354479643882004483/Btnfm47p.jpg")
        twitterSupportUserDetail.url = URL(string: "https://help.twitter.com")
        twitterSupportUserDetail.user = twitterSupportUser
        twitterSupportUserDetail.userAttributedDescription = NSAttributedString(string: "Here to help. 💙")

        let twitterProfileImageDataAsset = DataAsset(context: viewContext)
        twitterProfileImageDataAsset.url = twitterUserDetail.profileImageURL
        twitterProfileImageDataAsset.data = NSDataAsset(name: "TwitterProfileImageData")?.data

        let appleUser = User(context: viewContext)
        appleUser.creationDate = now
        appleUser.lastUpdateStartDate = now
        appleUser.lastUpdateEndDate = now
        appleUser.modificationDate = now
        appleUser.id = "380749300"

        let appleUserDetail = UserDetail(context: viewContext)
        appleUserDetail.creationDate = now
        appleUserDetail.followerUsersCount = 0
        appleUserDetail.followingUsersCount = 0
        appleUserDetail.userCreationDate = Date(timeIntervalSinceReferenceDate: 1317099723)
        appleUserDetail.location = "Cupertino, CA"
        appleUserDetail.name = "Apple"
        appleUserDetail.username = "Apple"
        appleUserDetail.profileImageURL = URL(string: "https://pbs.twimg.com/profile_images/1283958620359516160/p7zz5dxZ.jpg")
        appleUserDetail.url = nil
        appleUserDetail.user = appleUser
        appleUserDetail.userAttributedDescription = NSAttributedString(string: "Apple.com", attributes: [.link: URL(string: "http://Apple.com")!])

        let appleProfileImageDataAsset = DataAsset(context: viewContext)
        appleProfileImageDataAsset.url = appleUserDetail.profileImageURL
        appleProfileImageDataAsset.data = NSDataAsset(name: "AppleProfileImageData")?.data

        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
#endif
