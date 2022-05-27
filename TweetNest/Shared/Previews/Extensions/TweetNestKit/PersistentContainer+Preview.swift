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
    nonisolated func injectPreviewData(
        context: NSManagedObjectContext? = nil,
        save: Bool = false
    ) {
        injectPreviewData(manifest: "PreviewManifest", context: context, save: save)
    }

    @usableFromInline
    nonisolated func injectPreviewData(
        manifest resourceName: String,
        bundle: Bundle = .main,
        context: NSManagedObjectContext? = nil,
        save: Bool = false
    ) {
        guard context != nil || save else {
            fatalError("Should provide context parameter or set save parameter true")
        }
        let context = context ?? newBackgroundContext()
        guard let dataAsset = NSDataAsset(name: resourceName, bundle: bundle) else {
            fatalError("Cannot find preview manifest asset with given name: \(resourceName)")
        }
        let decoder = PropertyListDecoder()
        let previewManifest: PreviewManifest
        do {
            previewManifest = try decoder.decode(PreviewManifest.self, from: dataAsset.data)
        } catch let error as NSError {
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
            guard let userDetail = state.userIDToUserDetail[userID] else {
                continue
            }
            state.userDetail = userDetail
            _injectPreviewAccount(userID: userID, state: state, context: context)
        }
        for (userID, previewUserDataAssets) in previewManifest.dataAssets {
            guard let userDetail = state.userIDToUserDetail[userID] else {
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
                } catch let error as NSError {
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
    private nonisolated func _injectPreviewAccount(
        userID: String,
        state: _PreviewDataInjectionState,
        context: NSManagedObjectContext? = nil,
        save: Bool = false
    ) -> ManagedAccount {
        guard context != nil || save else {
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
                } catch let error as NSError {
                    fatalError("Cannot save context: \(context) (\(error), \(error.userInfo))")
                }
            }
        }
        return account
    }

    @discardableResult
    private nonisolated func _injectPreviewUser(
        id userID: String,
        state: _PreviewDataInjectionState,
        context: NSManagedObjectContext? = nil,
        save: Bool = false
    ) -> ManagedUser {
        guard context != nil || save else {
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
                } catch let error as NSError {
                    fatalError("Cannot save context: \(context) (\(error), \(error.userInfo))")
                }
            }
        }
        return user
    }

    @discardableResult
    private nonisolated func _injectPreviewUserDataAsset(
        _ previewUserDataAsset: PreviewManifest.UserDataAsset,
        state: _PreviewDataInjectionState,
        context: NSManagedObjectContext? = nil,
        save: Bool = false
    ) -> ManagedUserDataAsset {
        guard context != nil || save else {
            fatalError("Should provide context parameter or set save parameter true")
        }
        let context = context ?? newBackgroundContext()
        var userDataAsset: ManagedUserDataAsset!
        context.performAndWait {
            guard let dataAsset = NSDataAsset(name: previewUserDataAsset.dataResourceName, bundle: state.bundle) else {
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
                } catch let error as NSError {
                    fatalError("Cannot save context: \(context) (\(error), \(error.userInfo))")
                }
            }
        }
        return userDataAsset
    }

    @discardableResult
    private nonisolated func _injectPreviewUserDetail(
        _ previewUserDetail: PreviewManifest.UserDetail,
        state: _PreviewDataInjectionState,
        context: NSManagedObjectContext? = nil,
        save: Bool = false
    ) -> ManagedUserDetail {
        guard context != nil || save else {
            fatalError("Should provide context parameter or set save parameter true")
        }
        let context = context ?? newBackgroundContext()
        var userDetail: ManagedUserDetail!
        context.performAndWait {
            userDetail = ManagedUserDetail(context: context)
            if previewUserDetail.inherits == true, let latestUserDetail = state.userDetail {
                let attributeNames = ManagedUserDetail.entity().attributesByName.keys
                userDetail.setValuesForKeys(.init(uniqueKeysWithValues: attributeNames.map({($0, latestUserDetail.value(forKey: $0) as Any)})))
                userDetail.creationDate = nil
            }
            func assign<T>(_ value: T?, to keyPath: ReferenceWritableKeyPath<ManagedUserDetail, T>) {
                if let value = value {
                    userDetail[keyPath: keyPath] = value
                }
            }
            func assign<T>(_ value: T?, to keyPath: ReferenceWritableKeyPath<ManagedUserDetail, T?>, default: T? = nil) {
                if let value = value {
                    userDetail[keyPath: keyPath] = value
                } else if userDetail![keyPath: keyPath] == nil, let `default` = `default` {
                    userDetail[keyPath: keyPath] = `default`
                }
            }
            assign(previewUserDetail.blockingUserIDs, to: \.blockingUserIDs)
            assign(previewUserDetail.creationDate, to: \.creationDate, default: .now)
            assign(previewUserDetail.followerUserIDs, to: \.followerUserIDs)
            assign(previewUserDetail.followerUsersCount.flatMap({.init($0)}), to: \.followerUsersCount)
            assign(previewUserDetail.followingUserIDs, to: \.followingUserIDs)
            assign(previewUserDetail.followingUsersCount.flatMap({.init($0)}), to: \.followingUsersCount)
            assign(previewUserDetail.isProtected, to: \.isProtected)
            assign(previewUserDetail.isVerified, to: \.isVerified)
            assign(previewUserDetail.listedCount.flatMap({.init($0)}), to: \.listedCount)
            assign(previewUserDetail.location, to: \.location)
            assign(previewUserDetail.mutingUserIDs, to: \.mutingUserIDs)
            assign(previewUserDetail.name, to: \.name)
            assign(previewUserDetail.profileHeaderImageURL, to: \.profileHeaderImageURL)
            assign(previewUserDetail.profileImageURL, to: \.profileImageURL)
            assign(previewUserDetail.tweetsCount.flatMap({.init($0)}), to: \.tweetsCount)
            assign(previewUserDetail.url, to: \.url)
            assign(previewUserDetail.userAttributedDescription.flatMap({.init($0)}), to: \.userAttributedDescription)
            assign(previewUserDetail.userCreationDate, to: \.userCreationDate)
            assign(previewUserDetail.userID, to: \.userID)
            assign(previewUserDetail.username, to: \.username)
            if save {
                do {
                    try context.save()
                } catch let error as NSError {
                    fatalError("Cannot save context: \(context) (\(error), \(error.userInfo))")
                }
            }
        }
        return userDetail
    }
}
#endif
