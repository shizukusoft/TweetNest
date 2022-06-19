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

        case accounts = "Accounts"

        case dataAssets = "Data Assets"

        case userDetails = "User Details"
    }
}

extension PreviewManifest.UserDataAsset: Codable {

    private enum CodingKeys: String, CodingKey {

        case creationDate = "Creation Date"

        case dataMIMEType = "Data MIME Type"

        case dataResourceName = "Data Resource Name"

        case url = "URL"
    }
}

extension PreviewManifest.UserDetail: Codable {

    private enum CodingKeys: String, CodingKey {

        case blockingUserIDs = "Blocking User IDs"

        case creationDate = "Creation Date"

        case followerUserIDs = "Follower User IDs"

        case followerUsersCount = "Follower Users Count"

        case followingUserIDs = "Following User IDs"

        case followingUsersCount = "Following Users Count"

        case inherits = "Inherits"

        case isProtected = "Is Protected"

        case isVerified = "Is Verified"

        case listedCount = "Listed Count"

        case location = "Location"

        case mutingUserIDs = "Muting User IDs"

        case name = "Name"

        case profileHeaderImageURL = "Profile Header Image URL"

        case profileImageURL = "Profile Image URL"

        case tweetsCount = "Tweets Count"

        case url = "URL"

        case userAttributedDescription = "User Attributed Description"

        case userCreationDate = "User Creation Date"

        case userID = "User ID"

        case username = "Username"
    }
}
#endif
