//
//  PersistentContainer+Preview.swift
//  TweetNest
//
//  Created by Mina Her on 2022/05/26.
//

#if DEBUG
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#else
#error("AppKit or UIKit required.")
#endif

import CoreData
import Foundation
import TweetNestKit

extension PersistentContainer {

    @inlinable
    nonisolated func injectPreviewData(context: NSManagedObjectContext? = nil) {
        injectPreviewData(manifest: "PreviewManifest", context: context)
    }

    @usableFromInline
    nonisolated func injectPreviewData(manifest resourceName: String, bundle: Bundle = .main, context: NSManagedObjectContext? = nil) {
        let context = context ?? newBackgroundContext()
        guard let dataAsset = NSDataAsset(name: resourceName, bundle: bundle)
        else {
            fatalError("Cannot find preview manifest asset with given name: \(resourceName)")
        }
        let decoder = PropertyListDecoder()
        let previewManifest: PreviewManifest
        do {
            previewManifest = try decoder.decode(PreviewManifest.self, from: dataAsset.data)
        }
        catch let error as NSError {
            fatalError("Error has occurred while decoding contents of the preview manifest asset: \(resourceName) (\(error), \(error.userInfo))")
        }
        context.performAndWait {
            let now = Date.now
            var userIDToFirstUserDetail = [String: ManagedUserDetail]()
            for (userID, previewUserDetails) in previewManifest.userDetails {
                var latestUserDetail: ManagedUserDetail? = nil
                for previewUserDetail in previewUserDetails {
                    let userDetail = ManagedUserDetail(context: context)
                    if previewUserDetail.inherits == true, let latestUserDetail = latestUserDetail {
                        userDetail.blockingUserIDs = latestUserDetail.blockingUserIDs
                        userDetail.followerUserIDs = latestUserDetail.followerUserIDs
                        userDetail.followerUsersCount = latestUserDetail.followerUsersCount
                        userDetail.followingUserIDs = latestUserDetail.followingUserIDs
                        userDetail.followingUsersCount = latestUserDetail.followingUsersCount
                        userDetail.isProtected = latestUserDetail.isProtected
                        userDetail.isVerified = latestUserDetail.isVerified
                        userDetail.listedCount = latestUserDetail.listedCount
                        userDetail.location = latestUserDetail.location
                        userDetail.mutingUserIDs = latestUserDetail.mutingUserIDs
                        userDetail.name = latestUserDetail.name
                        userDetail.profileHeaderImageURL = latestUserDetail.profileHeaderImageURL
                        userDetail.profileImageURL = latestUserDetail.profileImageURL
                        userDetail.tweetsCount = latestUserDetail.tweetsCount
                        userDetail.url = latestUserDetail.url
                        userDetail.userAttributedDescription = latestUserDetail.userAttributedDescription
                        userDetail.userCreationDate = latestUserDetail.userCreationDate
                        userDetail.userID = latestUserDetail.userID
                        userDetail.username = latestUserDetail.username
                    }
                    if let blockingUserIDs = previewUserDetail.blockingUserIDs {
                        userDetail.blockingUserIDs = blockingUserIDs
                    }
                    if let creationDate = previewUserDetail.creationDate {
                        userDetail.creationDate = creationDate
                    }
                    else {
                        userDetail.creationDate = now
                    }
                    if let followerUserIDs = previewUserDetail.followerUserIDs {
                        userDetail.followerUserIDs = followerUserIDs
                    }
                    if let followerUsersCount = previewUserDetail.followerUsersCount {
                        userDetail.followerUsersCount = .init(followerUsersCount)
                    }
                    if let followingUserIDs = previewUserDetail.followingUserIDs {
                        userDetail.followingUserIDs = followingUserIDs
                    }
                    if let followingUsersCount = previewUserDetail.followingUsersCount {
                        userDetail.followingUsersCount = .init(followingUsersCount)
                    }
                    if let isProtected = previewUserDetail.isProtected {
                        userDetail.isProtected = isProtected
                    }
                    if let isVerified = previewUserDetail.isVerified {
                        userDetail.isVerified = isVerified
                    }
                    if let listedCount = previewUserDetail.listedCount {
                        userDetail.listedCount = .init(listedCount)
                    }
                    if let location = previewUserDetail.location {
                        userDetail.location = location
                    }
                    if let mutingUserIDs = previewUserDetail.mutingUserIDs {
                        userDetail.mutingUserIDs = mutingUserIDs
                    }
                    if let name = previewUserDetail.name {
                        userDetail.name = name
                    }
                    if let profileHeaderImageURL = previewUserDetail.profileHeaderImageURL {
                        userDetail.profileHeaderImageURL = profileHeaderImageURL
                    }
                    if let profileImageURL = previewUserDetail.profileImageURL {
                        userDetail.profileImageURL = profileImageURL
                    }
                    if let tweetsCount = previewUserDetail.tweetsCount {
                        userDetail.tweetsCount = .init(tweetsCount)
                    }
                    if let url = previewUserDetail.url {
                        userDetail.url = url
                    }
                    if let userAttributedDescription = previewUserDetail.userAttributedDescription {
                        userDetail.userAttributedDescription = .init(userAttributedDescription)
                    }
                    if let userCreationDate = previewUserDetail.userCreationDate {
                        userDetail.userCreationDate = userCreationDate
                    }
                    if let userID = previewUserDetail.userID {
                        userDetail.userID = userID
                    }
                    else if userDetail.userID == nil {
                        userDetail.userID = userID
                    }
                    if let username = previewUserDetail.username {
                        userDetail.username = username
                    }
                    if userIDToFirstUserDetail[userID] == nil {
                        userIDToFirstUserDetail[userID] = userDetail
                    }
                    latestUserDetail = userDetail
                }
            }
            for (userID, userDetail) in userIDToFirstUserDetail {
                let user = ManagedUser(context: context)
                user.lastUpdateStartDate = now
                user.creationDate = userDetail.creationDate ?? now
                user.id = userID
                user.lastUpdateEndDate = now
            }
            for userID in previewManifest.accounts {
                guard let userDetail = userIDToFirstUserDetail[userID]
                else {
                    continue
                }
                let account = ManagedAccount(context: context)
                account.creationDate = userDetail.creationDate ?? now
                account.preferences.fetchBlockingUsers = true
                account.preferences.fetchMutingUsers = true
                account.userID = userID
            }
            for (userID, previewUserDataAssets) in previewManifest.dataAssets {
                guard userIDToFirstUserDetail[userID] != nil
                else {
                    continue
                }
                for previewUserDataAsset in previewUserDataAssets {
                    guard let dataAsset = NSDataAsset(name: previewUserDataAsset.dataResourceName, bundle: bundle)
                    else {
                        fatalError("Cannot find provided asset with given name: \(previewUserDataAsset.dataResourceName)")
                    }
                    let userDataAsset = ManagedUserDataAsset(context: context)
                    userDataAsset.creationDate = previewUserDataAsset.creationDate ?? now
                    userDataAsset.data = dataAsset.data
                    userDataAsset.dataMIMEType = previewUserDataAsset.dataMIMEType
                    userDataAsset.url = previewUserDataAsset.url
                }
            }
            userIDToFirstUserDetail.removeAll()
            do {
                try context.save()
            }
            catch let error as NSError {
                fatalError("Cannot save context: \(context) (\(error), \(error.userInfo))")
            }
        }
    }
}
#endif
