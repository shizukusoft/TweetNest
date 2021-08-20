//
//  Session+UpdateAccount.swift
//  Session+UpdateAccount
//
//  Created by Jaehong Kang on 2021/08/16.
//

import Foundation
import CoreData
import Twitter
import OrderedCollections

extension Session {
    @discardableResult
    public nonisolated func updateAccount(_ accountObjectID: NSManagedObjectID) async throws -> Bool {
        let context = self.container.newBackgroundContext()
        context.undoManager = nil

        let updateStartDate = Date()
        let (accountID, accountPreferences) = try await context.perform { () -> (Int64, Account.Preferences) in
            guard let account = context.object(with: accountObjectID) as? Account else {
                throw SessionError.unknown
            }

            account.user?.lastUpdateStartDate = updateStartDate
            account.user?.lastUpdateEndDate = nil

            try context.save()

            return (account.id, account.preferences)
        }

        let twitterSession = try await self.twitterSession(for: accountID)

        let userID = String(accountID)

        async let _twitterUser = Twitter.User(id: userID, session: twitterSession)
        async let _followingUserIDs = Twitter.User.followingUserIDs(forUserID: userID, session: twitterSession)
        async let _followerIDs = Twitter.User.followerIDs(forUserID: userID, session: twitterSession)
        async let _myBlockingUserIDs = accountPreferences.fetchBlockingUsers ? Twitter.User.myBlockingUserIDs(session: twitterSession) : nil

        let twitterUser = try await _twitterUser
        async let _profileImageDataAsset = DataAsset.dataAsset(for: twitterUser.profileImageOriginalURL, session: self, context: context)

        let followingUserIDs = try await _followingUserIDs
        let followerIDs = try await _followerIDs
        let myBlockingUserIDs = try await _myBlockingUserIDs
        let twitterUserFetchDate = Date()

        async let hasChanges: Bool = context.perform(schedule: .enqueued) {
            let account = context.object(with: accountObjectID) as? Account

            let fetchRequest = User.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", userID)
            fetchRequest.relationshipKeyPathsForPrefetching = ["userDetails"]

            let user = try context.fetch(fetchRequest).last
            let previousUserDetail = user?.sortedUserDetails?.last

            let userDetail = try UserDetail.createOrUpdate(
                twitterUser: twitterUser,
                followingUserIDs: followingUserIDs,
                followerUserIDs: followerIDs,
                blockingUserIDs: myBlockingUserIDs,
                userUpdateStartDate: updateStartDate,
                userDetailCreationDate: twitterUserFetchDate,
                context: context
            )

            userDetail.user?.account = account

            try context.save()

            return previousUserDetail?.objectID != userDetail.objectID
        }
        
        var userIDs = OrderedSet<Twitter.User.ID>(followingUserIDs + followerIDs)
        if let myBlockingUserIDs = myBlockingUserIDs {
            userIDs.append(contentsOf: myBlockingUserIDs)
        }
        
        try await self.updateUsers(ids: userIDs, with: twitterSession)
        
        _ = try await _profileImageDataAsset

        return try await hasChanges
    }
}
