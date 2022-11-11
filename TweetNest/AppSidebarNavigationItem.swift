//
//  AppSidebarNavigationItem.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2022/08/28.
//

import Foundation
import Twitter
import TweetNestKit

enum AppSidebarNavigationItem: Hashable {
    case profile(accountManagedObjectID: URL, accountUserID: Twitter.User.ID)
    case followings(accountManagedObjectID: URL, accountUserID: Twitter.User.ID)
    case followers(accountManagedObjectID: URL, accountUserID: Twitter.User.ID)
    case blockings(accountManagedObjectID: URL, accountUserID: Twitter.User.ID)
    case mutings(accountManagedObjectID: URL, accountUserID: Twitter.User.ID)
}

extension AppSidebarNavigationItem {
    enum ItemType: Hashable, Codable {
        case profile
        case followings
        case followers
        case blockings
        case mutings
    }

    var itemType: ItemType {
        switch self {
        case .profile:
            return .profile
        case .followings:
            return .followings
        case .followers:
            return .followers
        case .blockings:
            return .blockings
        case .mutings:
            return .mutings
        }
    }
}

extension AppSidebarNavigationItem: Codable {
    enum CodingKeys: CodingKey {
        case itemType
        case accountManagedObjectID
        case accountUserID
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let itemType = try container.decode(ItemType.self, forKey: .itemType)
        switch itemType {
        case .profile:
            let accountManagedObjectID = try container.decode(URL.self, forKey: .accountManagedObjectID)
            let accountUserID = try container.decode(Twitter.User.ID.self, forKey: .accountUserID)

            self = .profile(accountManagedObjectID: accountManagedObjectID, accountUserID: accountUserID)
        case .followings:
            let accountManagedObjectID = try container.decode(URL.self, forKey: .accountManagedObjectID)
            let accountUserID = try container.decode(Twitter.User.ID.self, forKey: .accountUserID)

            self = .followings(accountManagedObjectID: accountManagedObjectID, accountUserID: accountUserID)
        case .followers:
            let accountManagedObjectID = try container.decode(URL.self, forKey: .accountManagedObjectID)
            let accountUserID = try container.decode(Twitter.User.ID.self, forKey: .accountUserID)

            self = .followers(accountManagedObjectID: accountManagedObjectID, accountUserID: accountUserID)
        case .blockings:
            let accountManagedObjectID = try container.decode(URL.self, forKey: .accountManagedObjectID)
            let accountUserID = try container.decode(Twitter.User.ID.self, forKey: .accountUserID)

            self = .blockings(accountManagedObjectID: accountManagedObjectID, accountUserID: accountUserID)
        case .mutings:
            let accountManagedObjectID = try container.decode(URL.self, forKey: .accountManagedObjectID)
            let accountUserID = try container.decode(Twitter.User.ID.self, forKey: .accountUserID)

            self = .mutings(accountManagedObjectID: accountManagedObjectID, accountUserID: accountUserID)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(itemType, forKey: .itemType)

        switch self {
        case .profile(accountManagedObjectID: let accountManagedObjectID, accountUserID: let accountUserID):
            try container.encode(accountManagedObjectID, forKey: .accountManagedObjectID)
            try container.encode(accountUserID, forKey: .accountUserID)
        case .followings(accountManagedObjectID: let accountManagedObjectID, accountUserID: let accountUserID):
            try container.encode(accountManagedObjectID, forKey: .accountManagedObjectID)
            try container.encode(accountUserID, forKey: .accountUserID)
        case .followers(accountManagedObjectID: let accountManagedObjectID, accountUserID: let accountUserID):
            try container.encode(accountManagedObjectID, forKey: .accountManagedObjectID)
            try container.encode(accountUserID, forKey: .accountUserID)
        case .blockings(accountManagedObjectID: let accountManagedObjectID, accountUserID: let accountUserID):
            try container.encode(accountManagedObjectID, forKey: .accountManagedObjectID)
            try container.encode(accountUserID, forKey: .accountUserID)
        case .mutings(accountManagedObjectID: let accountManagedObjectID, accountUserID: let accountUserID):
            try container.encode(accountManagedObjectID, forKey: .accountManagedObjectID)
            try container.encode(accountUserID, forKey: .accountUserID)
        }
    }
}
