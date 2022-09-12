//
//  PreviewManifest.swift
//  TweetNest
//
//  Created by Mina Her on 2022/05/26.
//

#if DEBUG
import Foundation

struct PreviewManifest {

    var accounts: [UserID]

    var dataAssets: [UserID: [UserDataAsset]]

    var userDetails: [UserID: [UserDetail]]
}

extension PreviewManifest {

    typealias ResourceName = String

    typealias UserID = String

    struct UserDataAsset {

        var creationDate: Date?

        var dataResourceName: String

        var dataMIMEType: String?

        var url: URL?
    }

    struct UserDetail {

        var blockingUserIDs: [UserID]?

        var creationDate: Date?

        var followerUserIDs: [UserID]?

        var followerUsersCount: Int?

        var followingUserIDs: [UserID]?

        var followingUsersCount: Int?

        var inherits: Bool?

        var isProtected: Bool?

        var isVerified: Bool?

        var listedCount: Int?

        var location: String?

        var mutingUserIDs: [UserID]?

        var name: String?

        var profileHeaderImageURL: URL?

        var profileImageURL: URL?

        var tweetsCount: Int?

        var url: URL?

        var userAttributedDescription: AttributedString?

        var userCreationDate: Date?

        var userID: UserID?

        var username: String?
    }
}

extension PreviewManifest: Codable {

    private enum CodingKeys: String, CodingKey {

        case accounts = "accounts"

        case dataAssets = "data-assets"

        case userDetails = "user-details"
    }
}

extension PreviewManifest.UserDataAsset: Codable {

    private enum CodingKeys: String, CodingKey {

        case creationDate = "creation-date"

        case dataMIMEType = "data-mime-type"

        case dataResourceName = "data-resource-name"

        case url = "url"
    }
}

extension PreviewManifest.UserDetail: Codable {

    private enum CodingKeys: String, CodingKey {

        case blockingUserIDs = "blocking-user-ids"

        case creationDate = "creation-date"

        case followerUserIDs = "follower-user-ids"

        case followerUsersCount = "follower-users-count"

        case followingUserIDs = "following-user-ids"

        case followingUsersCount = "following-users-count"

        case inherits = "inherits"

        case isProtected = "is-protected"

        case isVerified = "is-verified"

        case listedCount = "listed-count"

        case location = "location"

        case mutingUserIDs = "muting-user-ids"

        case name = "name"

        case profileHeaderImageURL = "profile-header-image-url"

        case profileImageURL = "profile-image-url"

        case tweetsCount = "tweets-count"

        case url = "url"

        case userAttributedDescription = "user-attributed-description"

        case userCreationDate = "user-creation-date"

        case userID = "user-id"

        case username = "username"
    }
}
#endif
