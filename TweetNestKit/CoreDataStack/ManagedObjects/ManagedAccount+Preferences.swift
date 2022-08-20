//
//  ManagedAccount+Preferences.swift
//  ManagedAccount+Preferences
//
//  Created by Jaehong Kang on 2021/08/16.
//

import Foundation

extension ManagedAccount {
    public struct Preferences {
        public var fetchBlockingUsers: Bool = false
        public var fetchMutingUsers: Bool = false
    }
}

extension ManagedAccount.Preferences: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let defaultPreferences = ManagedAccount.Preferences()

        self.fetchBlockingUsers = try container.decodeIfPresent(Bool.self, forKey: .fetchBlockingUsers) ?? defaultPreferences.fetchBlockingUsers
        self.fetchMutingUsers = try container.decodeIfPresent(Bool.self, forKey: .fetchMutingUsers) ?? defaultPreferences.fetchMutingUsers
    }
}

@objc
class ManagedAccountPreferencesTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        NSData.self
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let value = value as? ManagedAccount.Preferences? else {
            preconditionFailure()
        }

        return value.flatMap {
            do {
                return try PropertyListEncoder().encode($0) as NSData
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let value = value as? NSData else {
            return nil
        }

        return try? PropertyListDecoder().decode(ManagedAccount.Preferences.self, from: value as Data)
    }
}
