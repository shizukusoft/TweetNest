//
//  ManagedPreferencesV2+Preferences.swift
//  TweetNestKit
//
//  Created by 강재홍 on 2022/05/03.
//

import Foundation
import CoreData

extension ManagedPreferencesV2 {
    public struct Preferences {
        public var notifyProfileChanges: Bool = true
        public var notifyFollowingChanges: Bool = true
        public var notifyFollowerChanges: Bool = true
        public var notifyBlockingChanges: Bool = false
        public var notifyMutingChanges: Bool = false
    }
}

extension ManagedPreferencesV2.Preferences: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let defaultPreferences = ManagedPreferencesV2.Preferences()

        self.notifyProfileChanges = try container.decodeIfPresent(Bool.self, forKey: .notifyProfileChanges) ?? defaultPreferences.notifyProfileChanges
        self.notifyFollowingChanges = try container.decodeIfPresent(Bool.self, forKey: .notifyFollowingChanges) ?? defaultPreferences.notifyFollowingChanges
        self.notifyFollowerChanges = try container.decodeIfPresent(Bool.self, forKey: .notifyFollowerChanges) ?? defaultPreferences.notifyFollowerChanges
        self.notifyBlockingChanges = try container.decodeIfPresent(Bool.self, forKey: .notifyBlockingChanges) ?? defaultPreferences.notifyBlockingChanges
        self.notifyMutingChanges = try container.decodeIfPresent(Bool.self, forKey: .notifyMutingChanges) ?? defaultPreferences.notifyMutingChanges
    }
}

extension ManagedPreferencesV2.Preferences {
    public init(for context: NSManagedObjectContext) {
        self = context.performAndWait {
            ManagedPreferencesV2.managedPreferences(for: context).preferences
        }
    }

    public init(for context: NSManagedObjectContext) async {
        self = await context.perform {
            ManagedPreferencesV2.managedPreferences(for: context).preferences
        }
    }
}
