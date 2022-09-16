//
//  ManagedUserDetail+CoreDataClass.swift
//  TweetNestKit
//
//  Created by 강재홍 on 2022/05/03.
//
//

import Foundation
import CoreData
import TwitterV1
import OrderedCollections

public final class ManagedUserDetail: ManagedObject {

}

extension ManagedUserDetail {
    @discardableResult
    static func createOrUpdate(
        twitterUser: TwitterV1.User,
        followingUserIDs: [String]? = nil,
        followerUserIDs: [String]? = nil,
        blockingUserIDs: [String]? = nil,
        mutingUserIDs: [String]? = nil,
        creationDate: Date = Date(),
        previousUserDetail: ManagedUserDetail? = nil,
        context: NSManagedObjectContext
    ) throws -> ManagedUserDetail {
        let newUserDetail = ManagedUserDetail(context: context)
        newUserDetail.userID = String(twitterUser.id)

        newUserDetail.blockingUserIDs = blockingUserIDs
        newUserDetail.followingUserIDs = followingUserIDs
        newUserDetail.followerUserIDs = followerUserIDs
        newUserDetail.mutingUserIDs = mutingUserIDs

        newUserDetail.followerUsersCount = Int32(twitterUser.followersCount)
        newUserDetail.followingUsersCount = Int32(twitterUser.friendsCount)
        newUserDetail.isProtected = twitterUser.isProtected
        newUserDetail.isVerified = twitterUser.isVerified
        newUserDetail.listedCount = Int32(twitterUser.listedCount)
        newUserDetail.location = twitterUser.location
        newUserDetail.name = twitterUser.name
        newUserDetail.profileHeaderImageURL = twitterUser.profileBannerOriginalURL
        newUserDetail.profileImageURL = twitterUser.profileImageOriginalURL
        newUserDetail.tweetsCount = Int32(twitterUser.statusesCount)
        newUserDetail.url = twitterUser.expandedURL
        newUserDetail.userCreationDate = twitterUser.createdAt
        newUserDetail.userAttributedDescription = twitterUser.attributedDescription.flatMap({ NSAttributedString($0) })
        newUserDetail.username = twitterUser.screenName

        if let previousUserDetail = previousUserDetail, previousUserDetail ~= newUserDetail {
            context.delete(newUserDetail)

            return previousUserDetail
        } else {
            newUserDetail.creationDate = creationDate

            return newUserDetail
        }
    }
}

extension ManagedUserDetail {
    public var displayUsername: String? {
        username.flatMap {
            "@\($0)"
        }
    }
}

extension ManagedUserDetail {
    static func ~= (lhs: ManagedUserDetail, rhs: ManagedUserDetail) -> Bool {
        lhs.isProfileEqual(to: rhs) &&
        lhs.followerUsersCount == rhs.followerUsersCount &&
        lhs.followingUsersCount == rhs.followingUsersCount &&
        lhs.listedCount == rhs.listedCount &&
        lhs.tweetsCount == rhs.tweetsCount &&
        lhs.blockingUserIDs == rhs.blockingUserIDs &&
        lhs.followingUserIDs == rhs.followingUserIDs &&
        lhs.followerUserIDs == rhs.followerUserIDs &&
        lhs.mutingUserIDs == rhs.mutingUserIDs
    }
}

extension Optional where Wrapped == ManagedUserDetail {
    static func ~= (lhs: ManagedUserDetail?, rhs: ManagedUserDetail?) -> Bool {
        switch (lhs, rhs) {
        case (.some, .none), (.none, .some):
            return false
        case (.none, .none):
            return true
        case (.some(let lhs), .some(let rhs)):
            return lhs ~= rhs
        }
    }
}

extension ManagedUserDetail {
    func isProfileEqual(to userDetail: ManagedUserDetail) -> Bool {
        isProtected == userDetail.isProtected &&
        isVerified == userDetail.isVerified &&
        location == userDetail.location &&
        name == userDetail.name &&
        profileHeaderImageURL == userDetail.profileHeaderImageURL &&
        profileImageURL == userDetail.profileImageURL &&
        url == userDetail.url &&
        userCreationDate == userDetail.userCreationDate &&
        userAttributedDescription == userDetail.userAttributedDescription &&
        username == userDetail.username
    }
}

extension ManagedUserDetail {
    struct UserIDsChange {
        let addedUserIDs: OrderedSet<String>
        let removedUserIDs: OrderedSet<String>
    }

    func userIDsChange(from oldUserDetail: ManagedUserDetail?, for keyPath: KeyPath<ManagedUserDetail, [String]?>) -> UserIDsChange? {
        let previousUserIDs = oldUserDetail == nil ? [] : oldUserDetail?[keyPath: keyPath].flatMap { OrderedSet($0) }
        let latestUserIDs = self[keyPath: keyPath].flatMap { OrderedSet($0) }

        guard let previousUserIDs = previousUserIDs, let latestUserIDs = latestUserIDs else {
            return nil
        }

        return UserIDsChange(
            addedUserIDs: latestUserIDs.subtracting(previousUserIDs),
            removedUserIDs: previousUserIDs.subtracting(latestUserIDs)
        )
    }
}

extension ManagedUserDetail {

    internal struct DetailedUserIDsChange {

        internal let addedUserIDs: OrderedSet<String>

        internal let removedUserIDs: OrderedSet<String>

        internal let friends: UserIDsChange

        internal let followings: UserIDsChange

        internal let followers: UserIDsChange

        internal let strangers: UserIDsChange

        internal let mutings: UserIDsChange

        internal let uniqueMutings: UserIDsChange

        internal let blockings: UserIDsChange

        internal let uniqueBlockings: UserIDsChange

        internal let others: UserIDsChange

        internal let component: Component

        internal init(
            addedUserIDs: OrderedSet<String>,
            removedUserIDs: OrderedSet<String>,
            compareTo comparisonTarget: ManagedUserDetail,
            forComponent component: Component
        ) {
            let friendUserIDs: Set<String>
            let followingUserIDs: Set<String>
            let followerUserIDs: Set<String>
            let followingFollowerUserIDs: Set<String>
            let mutingUserIDs: Set<String>
            let blockingUserIDs: Set<String>
            if component.contains(.followings) || component.contains(.friends) {
                followingUserIDs = comparisonTarget.followingUserIDs.flatMap(Set.init(_:)) ?? .init()
            } else {
                followingUserIDs = .init()
            }
            if component.contains(.followers) || component.contains(.friends) {
                followerUserIDs = comparisonTarget.followerUserIDs.flatMap(Set.init(_:)) ?? .init()
            } else {
                followerUserIDs = .init()
            }
            if component.contains(.friends) {
                if followingUserIDs.count < followerUserIDs.count {
                    friendUserIDs = followingUserIDs.intersection(followerUserIDs)
                } else {
                    friendUserIDs = followerUserIDs.intersection(followerUserIDs)
                }
            } else {
                friendUserIDs = .init()
            }
            if component.contains(.followings) {
                if component.contains(.followers) {
                    followingFollowerUserIDs = followingUserIDs.union(followerUserIDs)
                }
                else {
                    followingFollowerUserIDs = followingUserIDs
                }
            } else if component.contains(.followers) {
                followingFollowerUserIDs = followerUserIDs
            } else {
                followingFollowerUserIDs = .init()
            }
            if component.contains(.mutings) {
                mutingUserIDs = comparisonTarget.mutingUserIDs.flatMap(Set.init(_:)) ?? .init()
            } else {
                mutingUserIDs = .init()
            }
            if component.contains(.blockings) {
                blockingUserIDs = comparisonTarget.blockingUserIDs.flatMap(Set.init(_:)) ?? .init()
            } else {
                blockingUserIDs = .init()
            }
            var addedFriendUserIDs = OrderedSet<String>()
            var addedFollowingUserIDs = OrderedSet<String>()
            var addedFollowerUserIDs = OrderedSet<String>()
            var addedStrangerUserIDs = OrderedSet<String>()
            var addedMutingUserIDs = OrderedSet<String>()
            var addedBlockingUserIDs = OrderedSet<String>()
            var addedUniqueMutingUserIDs = OrderedSet<String>()
            var addedUniqueBlockingUserIDs = OrderedSet<String>()
            var addedOtherUserIDs = OrderedSet<String>()
            for userID in addedUserIDs {
                if friendUserIDs.contains(userID) {
                    addedFriendUserIDs.append(userID)
                } else if component.contains(.followings) && followingUserIDs.contains(userID) {
                    addedFollowingUserIDs.append(userID)
                } else if component.contains(.followers) && followerUserIDs.contains(userID) {
                    addedFollowerUserIDs.append(userID)
                } else {
                    addedStrangerUserIDs.append(userID)
                }
                if mutingUserIDs.contains(userID) {
                    addedMutingUserIDs.append(userID)
                    if !followingFollowerUserIDs.contains(userID) {
                        addedUniqueMutingUserIDs.append(userID)
                    }
                }
                if blockingUserIDs.contains(userID) {
                    addedBlockingUserIDs.append(userID)
                    if !followingFollowerUserIDs.contains(userID) {
                        addedUniqueBlockingUserIDs.append(userID)
                    }
                }
                if !(followingFollowerUserIDs.contains(userID) || mutingUserIDs.contains(userID) || blockingUserIDs.contains(userID)) {
                    addedOtherUserIDs.append(userID)
                }
            }
            var removedFriendUserIDs = OrderedSet<String>()
            var removedFollowingUserIDs = OrderedSet<String>()
            var removedFollowerUserIDs = OrderedSet<String>()
            var removedStrangerUserIDs = OrderedSet<String>()
            var removedMutingUserIDs = OrderedSet<String>()
            var removedBlockingUserIDs = OrderedSet<String>()
            var removedUniqueMutingUserIDs = OrderedSet<String>()
            var removedUniqueBlockingUserIDs = OrderedSet<String>()
            var removedOtherUserIDs = OrderedSet<String>()
            for userID in removedUserIDs {
                if friendUserIDs.contains(userID) {
                    removedFriendUserIDs.append(userID)
                } else if component.contains(.followings) && followingUserIDs.contains(userID) {
                    removedFollowingUserIDs.append(userID)
                } else if component.contains(.followers) && followerUserIDs.contains(userID) {
                    removedFollowerUserIDs.append(userID)
                } else {
                    removedStrangerUserIDs.append(userID)
                }
                if mutingUserIDs.contains(userID) {
                    removedMutingUserIDs.append(userID)
                    if !followingFollowerUserIDs.contains(userID) {
                        removedUniqueMutingUserIDs.append(userID)
                    }
                }
                if blockingUserIDs.contains(userID) {
                    removedBlockingUserIDs.append(userID)
                    if !followingFollowerUserIDs.contains(userID) {
                        removedUniqueBlockingUserIDs.append(userID)
                    }
                }
                if !(followingFollowerUserIDs.contains(userID) || mutingUserIDs.contains(userID) || blockingUserIDs.contains(userID)) {
                    removedOtherUserIDs.append(userID)
                }
            }
            self.addedUserIDs = addedUserIDs
            self.removedUserIDs = removedUserIDs
            self.friends = .init(addedUserIDs: addedFriendUserIDs, removedUserIDs: removedFriendUserIDs)
            self.followings = .init(addedUserIDs: addedFollowingUserIDs, removedUserIDs: removedFollowingUserIDs)
            self.followers = .init(addedUserIDs: addedFollowerUserIDs, removedUserIDs: removedFollowerUserIDs)
            self.strangers = .init(addedUserIDs: addedStrangerUserIDs, removedUserIDs: removedStrangerUserIDs)
            self.mutings = .init(addedUserIDs: addedMutingUserIDs, removedUserIDs: removedMutingUserIDs)
            self.uniqueMutings = .init(addedUserIDs: addedUniqueMutingUserIDs, removedUserIDs: removedUniqueMutingUserIDs)
            self.blockings = .init(addedUserIDs: addedBlockingUserIDs, removedUserIDs: removedBlockingUserIDs)
            self.uniqueBlockings = .init(addedUserIDs: addedUniqueBlockingUserIDs, removedUserIDs: removedUniqueBlockingUserIDs)
            self.others = .init(addedUserIDs: addedOtherUserIDs, removedUserIDs: removedOtherUserIDs)
            self.component = component
        }
    }

    internal func userIDsChange(
        from oldUserDetail: ManagedUserDetail?,
        for keyPath: KeyPath<ManagedUserDetail, [String]?>,
        component: DetailedUserIDsChange.Component = [.friends, .followings, .followers]
    ) -> DetailedUserIDsChange? {
        guard
            let oldUserDetail = oldUserDetail,
            let oldUserIDs = oldUserDetail[keyPath: keyPath].flatMap(OrderedSet.init(_:)),
            let newUserIDs = self[keyPath: keyPath].flatMap(OrderedSet.init(_:))
        else {
            return nil
        }
        return
            .init(
                addedUserIDs: newUserIDs.subtracting(oldUserIDs),
                removedUserIDs: oldUserIDs.subtracting(newUserIDs),
                compareTo: oldUserDetail,
                forComponent: component)
    }
}

extension ManagedUserDetail.DetailedUserIDsChange {

    internal struct Component: OptionSet {

        internal static let friends: Self = .init(rawValue: 1 << 0)

        internal static let followings: Self = .init(rawValue: 1 << 1)

        internal static let followers: Self = .init(rawValue: 1 << 2)

        internal static let mutings: Self = .init(rawValue: 1 << 3)

        internal static let blockings: Self = .init(rawValue: 1 << 4)

        internal var rawValue: UInt

        internal init(rawValue: UInt) {
            self.rawValue = rawValue
        }
    }
}
