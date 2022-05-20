//
//  Session+Preview.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/02/23.
//

#if DEBUG

import CoreData
import Foundation
import TweetNestKit
import UniformTypeIdentifiers

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#else
#error("AppKit or UIKit required.")
#endif

extension TweetNestKit.Session {

    public static let preview: Session = {
        let session = Session(inMemory: true)
        do {
            try session.insertPreviewDataToPersistentContainer()
        }
        catch let error as NSError {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
        return session
    }()
}

extension TweetNestKit.Session {
    nonisolated func insertPreviewDataToPersistentContainer() throws {
        let context = persistentContainer.newBackgroundContext()

        try context.performAndWait {
            insertPreviewTweetNestAccountToPersistentContainer(context: context)
            insertPreviewTwitterUsersToPersistentContainer(context: context)
            insertPreviewAppleUserToPersistentContainer(context: context)

            try context.save()
        }
    }

    nonisolated private func insertPreviewTweetNestAccountToPersistentContainer(context: NSManagedObjectContext) {
        let now = Date()

        let tweetnestAccount = ManagedAccount(context: context)
        tweetnestAccount.creationDate = Date(timeIntervalSince1970: 1628780400)
        tweetnestAccount.userID = "1352231658661920770"
        tweetnestAccount.preferences.fetchBlockingUsers = true
        tweetnestAccount.preferences.fetchMutingUsers = true

        let tweetnestUser = ManagedUser(context: context)
        tweetnestUser.creationDate = Date(timeIntervalSince1970: 1628780400)
        tweetnestUser.lastUpdateStartDate = now
        tweetnestUser.lastUpdateEndDate = now
        tweetnestUser.id = tweetnestAccount.userID

        let tweetnestUserDetail1 = ManagedUserDetail(context: context)
        tweetnestUserDetail1.creationDate = Date(timeIntervalSince1970: 1628780400)
        tweetnestUserDetail1.followerUserIDs = ["783214", "17874544"]
        tweetnestUserDetail1.followerUsersCount = 2
        tweetnestUserDetail1.followingUserIDs = ["783214", "17874544"]
        tweetnestUserDetail1.followingUsersCount = 2
        tweetnestUserDetail1.blockingUserIDs = []
        tweetnestUserDetail1.mutingUserIDs = []
        tweetnestUserDetail1.userCreationDate = Date(timeIntervalSince1970: 1616357217)
        tweetnestUserDetail1.location = "대한민국 서울"
        tweetnestUserDetail1.name = "TweetNest"
        tweetnestUserDetail1.username = "TweetNest_App"
        tweetnestUserDetail1.profileImageURL = URL(string: "https://pbs.twimg.com/profile_images/1373878674903113729/JL3SGoch.png")
        tweetnestUserDetail1.url = URL(string: "https://www.tweetnest.com")
        tweetnestUserDetail1.userID = tweetnestUser.id

        let tweetnestUserDetail2 = ManagedUserDetail(context: context)
        tweetnestUserDetail2.creationDate = Date(timeIntervalSince1970: 1631709579)
        tweetnestUserDetail2.followerUserIDs = ["783214"]
        tweetnestUserDetail2.followerUsersCount = 1
        tweetnestUserDetail2.followingUserIDs = ["783214"]
        tweetnestUserDetail2.followingUsersCount = 1
        tweetnestUserDetail1.blockingUserIDs = []
        tweetnestUserDetail1.mutingUserIDs = []
        tweetnestUserDetail2.userCreationDate = Date(timeIntervalSince1970: 1616357217)
        tweetnestUserDetail2.location = "대한민국 서울"
        tweetnestUserDetail2.name = "TweetNest"
        tweetnestUserDetail2.username = "TweetNest_App"
        tweetnestUserDetail2.profileImageURL = URL(string: "https://pbs.twimg.com/profile_images/1373878674903113729/JL3SGoch.png")
        tweetnestUserDetail2.url = URL(string: "https://www.tweetnest.com")
        tweetnestUserDetail2.userID = tweetnestUser.id

        let tweetnestUserDetail3 = ManagedUserDetail(context: context)
        tweetnestUserDetail3.creationDate = now
        tweetnestUserDetail3.followerUserIDs = ["783214", "380749300"]
        tweetnestUserDetail3.followerUsersCount = 2
        tweetnestUserDetail3.followingUserIDs = ["783214", "380749300"]
        tweetnestUserDetail3.followingUsersCount = 2
        tweetnestUserDetail1.blockingUserIDs = []
        tweetnestUserDetail1.mutingUserIDs = []
        tweetnestUserDetail3.userCreationDate = Date(timeIntervalSince1970: 1616357217)
        tweetnestUserDetail3.location = "대한민국 서울"
        tweetnestUserDetail3.name = "TweetNest"
        tweetnestUserDetail3.username = "TweetNest_App"
        tweetnestUserDetail3.profileImageURL = URL(string: "https://pbs.twimg.com/profile_images/1373878674903113729/JL3SGoch.png")
        tweetnestUserDetail3.url = URL(string: "https://www.tweetnest.com")
        tweetnestUserDetail3.userID = tweetnestUser.id

        let tweetnestProfileImageDataAsset = ManagedUserDataAsset(context: context)
        tweetnestProfileImageDataAsset.url = tweetnestUserDetail1.profileImageURL
        tweetnestProfileImageDataAsset.dataMIMEType = UTType.png.preferredMIMEType
        tweetnestProfileImageDataAsset.data = NSDataAsset(name: "TweetNestProfileImageData")?.data
    }

    nonisolated private func insertPreviewTwitterUsersToPersistentContainer(context: NSManagedObjectContext) {
        let now = Date()

        let twitterUser = ManagedUser(context: context)
        twitterUser.creationDate = now
        twitterUser.lastUpdateStartDate = now
        twitterUser.lastUpdateEndDate = now
        twitterUser.id = "783214"

        let twitterUserDetail = ManagedUserDetail(context: context)
        twitterUserDetail.creationDate = now
        twitterUserDetail.followerUsersCount = 0
        twitterUserDetail.followingUsersCount = 0
        twitterUserDetail.userCreationDate = Date(timeIntervalSinceReferenceDate: 1171982154)
        twitterUserDetail.location = "everywhere"
        twitterUserDetail.name = "Twitter"
        twitterUserDetail.username = "Twitter"
        twitterUserDetail.profileImageURL = URL(string: "https://pbs.twimg.com/profile_images/1354479643882004483/Btnfm47p.jpg")
        twitterUserDetail.url = URL(string: "https://about.twitter.com/")
        twitterUserDetail.userID = twitterUser.id
        twitterUserDetail.userAttributedDescription = NSAttributedString(string: "what’s happening?!")

        let twitterSupportUser = ManagedUser(context: context)
        twitterSupportUser.creationDate = now
        twitterSupportUser.lastUpdateStartDate = now
        twitterSupportUser.lastUpdateEndDate = now
        twitterSupportUser.id = "17874544"

        let twitterSupportUserDetail = ManagedUserDetail(context: context)
        twitterSupportUserDetail.creationDate = now
        twitterSupportUserDetail.followerUsersCount = 0
        twitterSupportUserDetail.followingUsersCount = 0
        twitterSupportUserDetail.userCreationDate = Date(timeIntervalSinceReferenceDate: 1228416717)
        twitterSupportUserDetail.location = "Twitter HQ"
        twitterSupportUserDetail.name = "Twitter Support"
        twitterSupportUserDetail.username = "TwitterSupport"
        twitterSupportUserDetail.profileImageURL = URL(string: "https://pbs.twimg.com/profile_images/1354479643882004483/Btnfm47p.jpg")
        twitterSupportUserDetail.url = URL(string: "https://help.twitter.com")
        twitterSupportUserDetail.userID = twitterSupportUser.id
        twitterSupportUserDetail.userAttributedDescription = NSAttributedString(string: "Here to help. 💙")

        let twitterProfileImageDataAsset = ManagedUserDataAsset(context: context)
        twitterProfileImageDataAsset.url = twitterUserDetail.profileImageURL
        twitterProfileImageDataAsset.dataMIMEType = UTType.jpeg.preferredMIMEType
        twitterProfileImageDataAsset.data = NSDataAsset(name: "TwitterProfileImageData")?.data
    }

    nonisolated private func insertPreviewAppleUserToPersistentContainer(context: NSManagedObjectContext) {
        let now = Date()

        let appleUser = ManagedUser(context: context)
        appleUser.creationDate = now
        appleUser.lastUpdateStartDate = now
        appleUser.lastUpdateEndDate = now
        appleUser.id = "380749300"

        let appleUserDetail = ManagedUserDetail(context: context)
        appleUserDetail.creationDate = now
        appleUserDetail.followerUsersCount = 0
        appleUserDetail.followingUsersCount = 0
        appleUserDetail.userCreationDate = Date(timeIntervalSinceReferenceDate: 1317099723)
        appleUserDetail.location = "Cupertino, CA"
        appleUserDetail.name = "Apple"
        appleUserDetail.username = "Apple"
        appleUserDetail.profileImageURL = URL(string: "https://pbs.twimg.com/profile_images/1283958620359516160/p7zz5dxZ.jpg")
        appleUserDetail.url = nil
        appleUserDetail.userID = appleUser.id
        appleUserDetail.userAttributedDescription = NSAttributedString(string: "Apple.com", attributes: [.link: URL(string: "http://Apple.com")!])

        let appleProfileImageDataAsset = ManagedUserDataAsset(context: context)
        appleProfileImageDataAsset.url = appleUserDetail.profileImageURL
        appleProfileImageDataAsset.dataMIMEType = UTType.jpeg.preferredMIMEType
        appleProfileImageDataAsset.data = NSDataAsset(name: "AppleProfileImageData")?.data
    }
}

#endif
