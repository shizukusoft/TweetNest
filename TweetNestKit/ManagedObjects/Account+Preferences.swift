//
//  Account+Preferences.swift
//  Account+Preferences
//
//  Created by Jaehong Kang on 2021/08/16.
//

import Foundation

extension Account {
    public struct Preferences {
        public var fetchBlockingUsers: Bool = false
    }
}

extension Account.Preferences: Codable { }

extension Account.Preferences {
    @objc(TWNKAccountPreferencesTransformer)
    class Transformer: ValueTransformer {
        override class func transformedValueClass() -> AnyClass {
            NSData.self
        }

        override func transformedValue(_ value: Any?) -> Any? {
            guard let value = value as? Account.Preferences? else {
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

            return try? PropertyListDecoder().decode(Account.Preferences.self, from: value as Data)
        }
    }
}
