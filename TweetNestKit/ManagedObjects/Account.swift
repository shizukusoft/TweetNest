//
//  Account.swift
//  TweetNestKit
//
//  Created by Jaehong Kang on 2021/02/24.
//

import Foundation
import CoreData

public class Account: NSManagedObject {
    
}

extension Account {
    struct Key {
        static let preferences = "preferences"
    }
    
    public dynamic var preferences: Preferences {
        get {
            willAccessValue(forKey: Key.preferences)
            defer { didAccessValue(forKey: Key.preferences) }
            
            let preferences = primitiveValue(forKey: Key.preferences) as? Preferences
            
            
            guard let preferences = preferences else {
                self.preferences = Preferences()
                return self.preferences
            }
            
            return preferences
        }
        set {
            willChangeValue(forKey: Key.preferences)
            defer { didChangeValue(forKey: Key.preferences) }
            
            setPrimitiveValue(newValue, forKey: Key.preferences)
        }
    }
}

extension Account {
    public var displayUsername: String {
        if let displayUsername = user?.displayUsername {
            return displayUsername
        }
        
        return description
    }
}
