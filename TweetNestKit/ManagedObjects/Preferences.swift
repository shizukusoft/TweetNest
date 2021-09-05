//
//  Preferences+CoreDataClass.swift
//  Preferences
//
//  Created by Jaehong Kang on 2021/09/05.
//
//

import Foundation
import CoreData

class Preferences: NSManagedObject {

}

extension Preferences {
    struct Key {
        static let preferences = "preferences"
    }

    public dynamic var preferences: Session.Preferences {
        get {
            willAccessValue(forKey: Key.preferences)
            defer { didAccessValue(forKey: Key.preferences) }

            let preferences = primitiveValue(forKey: Key.preferences) as? Session.Preferences


            guard let preferences = preferences else {
                self.preferences = Session.Preferences()
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
