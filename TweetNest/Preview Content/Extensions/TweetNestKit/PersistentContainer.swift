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
    nonisolated func injectPreviewData(context: NSManagedObjectContext? = nil, save: Bool = false) {
        injectPreviewData(manifest: "PreviewManifest", context: context, save: save)
    }

    @usableFromInline
    nonisolated func injectPreviewData(manifest resourceName: String, bundle: Bundle = .main, context: NSManagedObjectContext? = nil, save: Bool = false) {
        guard context != nil || save
        else {
            fatalError("Should provide context parameter or set save parameter true")
        }
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
        let state = _PreviewDataInjectionState(bundle: bundle)
        for (userID, previewUserDetails) in previewManifest.userDetails {
            state.userDetail = nil
            for previewUserDetail in previewUserDetails {
                let userDetail = _injectPreviewUserDetail(previewUserDetail, state: state, context: context)
                if state.userIDToUserDetail[userID] == nil {
                    state.userIDToUserDetail[userID] = userDetail
                }
                state.userDetail = userDetail
            }
        }
        for (userID, userDetail) in state.userIDToUserDetail {
            state.userDetail = userDetail
            _injectPreviewUser(id: userID, state: state, context: context)
        }
        for userID in previewManifest.accounts {
            guard let userDetail = state.userIDToUserDetail[userID]
            else {
                continue
            }
            state.userDetail = userDetail
            _injectPreviewAccount(userID: userID, state: state, context: context)
        }
        for (userID, previewUserDataAssets) in previewManifest.dataAssets {
            guard let userDetail = state.userIDToUserDetail[userID]
            else {
                continue
            }
            state.userDetail = userDetail
            for previewUserDataAsset in previewUserDataAssets {
                _injectPreviewUserDataAsset(previewUserDataAsset, state: state, context: context)
            }
        }
        if save {
            context.performAndWait {
                do {
                    try context.save()
                }
                catch let error as NSError {
                    fatalError("Cannot save context: \(context) (\(error), \(error.userInfo))")
                }
            }
        }
    }
}

extension PersistentContainer {

    private final class _PreviewDataInjectionState {

        let bundle: Bundle

        var userDetail: ManagedUserDetail?

        var userIDToUserDetail: [String: ManagedUserDetail] = .init()

        init(bundle: Bundle) {
            self.bundle = bundle
        }
    }

    @discardableResult
    private nonisolated func _injectPreviewAccount(userID: String, state: _PreviewDataInjectionState, context: NSManagedObjectContext? = nil, save: Bool = false) -> ManagedAccount {
        guard context != nil || save
        else {
            fatalError("Should provide context parameter or set save parameter true")
        }
        let context = context ?? newBackgroundContext()
        var account: ManagedAccount!
        context.performAndWait {
            account = ManagedAccount(context: context)
            account.creationDate = state.userDetail?.creationDate ?? .now
            account.preferences.fetchBlockingUsers = true
            account.preferences.fetchMutingUsers = true
            account.userID = userID
            if save {
                do {
                    try context.save()
                }
                catch let error as NSError {
                    fatalError("Cannot save context: \(context) (\(error), \(error.userInfo))")
                }
            }
        }
        return account
    }

    @discardableResult
    private nonisolated func _injectPreviewUser(id userID: String, state: _PreviewDataInjectionState, context: NSManagedObjectContext? = nil, save: Bool = false) -> ManagedUser {
        guard context != nil || save
        else {
            fatalError("Should provide context parameter or set save parameter true")
        }
        let context = context ?? newBackgroundContext()
        var user: ManagedUser!
        context.performAndWait {
            user = ManagedUser(context: context)
            user.lastUpdateStartDate = .now
            user.creationDate = state.userDetail?.creationDate ?? .now
            user.id = userID
            user.lastUpdateEndDate = .now
            if save {
                do {
                    try context.save()
                }
                catch let error as NSError {
                    fatalError("Cannot save context: \(context) (\(error), \(error.userInfo))")
                }
            }
        }
        return user
    }

    @discardableResult
    private nonisolated func _injectPreviewUserDataAsset(_ previewUserDataAsset: PreviewManifest.UserDataAsset, state: _PreviewDataInjectionState, context: NSManagedObjectContext? = nil, save: Bool = false) -> ManagedUserDataAsset {
        guard context != nil || save
        else {
            fatalError("Should provide context parameter or set save parameter true")
        }
        let context = context ?? newBackgroundContext()
        var userDataAsset: ManagedUserDataAsset!
        context.performAndWait {
            guard let dataAsset = NSDataAsset(name: previewUserDataAsset.dataResourceName, bundle: state.bundle)
            else {
                fatalError("Cannot find provided asset with given name: \(previewUserDataAsset.dataResourceName)")
            }
            userDataAsset = ManagedUserDataAsset(context: context)
            userDataAsset.creationDate = previewUserDataAsset.creationDate ?? .now
            userDataAsset.data = dataAsset.data
            userDataAsset.dataMIMEType = previewUserDataAsset.dataMIMEType
            userDataAsset.url = previewUserDataAsset.url
            if save {
                do {
                    try context.save()
                }
                catch let error as NSError {
                    fatalError("Cannot save context: \(context) (\(error), \(error.userInfo))")
                }
            }
        }
        return userDataAsset
    }

    @discardableResult
    private nonisolated func _injectPreviewUserDetail(_ previewUserDetail: PreviewManifest.UserDetail, state: _PreviewDataInjectionState, context: NSManagedObjectContext? = nil, save: Bool = false) -> ManagedUserDetail {
        guard context != nil || save
        else {
            fatalError("Should provide context parameter or set save parameter true")
        }
        let context = context ?? newBackgroundContext()
        var userDetail: ManagedUserDetail!
        context.performAndWait {
            userDetail = ManagedUserDetail(context: context)
            if previewUserDetail.inherits == true, let latestUserDetail = state.userDetail {
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
                userDetail.creationDate = .now
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
            if let username = previewUserDetail.username {
                userDetail.username = username
            }
            if save {
                do {
                    try context.save()
                }
                catch let error as NSError {
                    fatalError("Cannot save context: \(context) (\(error), \(error.userInfo))")
                }
            }
        }
        return userDetail
    }
}
#endif
