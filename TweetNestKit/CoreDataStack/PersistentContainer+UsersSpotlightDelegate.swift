//
//  PersistentContainer+UsersSpotlightDelegate.swift
//  PersistentContainer+UsersSpotlightDelegate
//
//  Created by Jaehong Kang on 2021/08/06.
//

#if canImport(CoreSpotlight)

import CoreData
import CoreSpotlight
import Algorithms

extension PersistentContainer {
    public class UsersSpotlightDelegate: NSCoreDataCoreSpotlightDelegate {
        public override func domainIdentifier() -> String {
            "\(Bundle.tweetNestKit.bundleIdentifier!).users"
        }

        public override func indexName() -> String? {
            "users-index"
        }

        public override func attributeSet(for object: NSManagedObject) -> CSSearchableItemAttributeSet? {
            if let user = object as? ManagedUser {
                let attributeSet = CSSearchableItemAttributeSet(contentType: .contact)

                attributeSet.identifier = user.id
                attributeSet.displayName = user.userDetails?.last?.name
                attributeSet.alternateNames = user.userDetails?.last?.username.flatMap { ["@\($0)"] }
                attributeSet.thumbnailData = try? user.userDetails?.last?.profileImageURL.flatMap {
                    let fetchRequest = ManagedUserDataAsset.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "url == %@", $0 as NSURL)
                    fetchRequest.sortDescriptors =  [
                        NSSortDescriptor(keyPath: \ManagedUserDataAsset.creationDate, ascending: false),
                    ]
                    fetchRequest.fetchLimit = 1

                    return try user.managedObjectContext?.fetch(fetchRequest).first?.data
                }

                var keywords = [String]()
                if let displayUserID = user.id?.displayUserID {
                    keywords.append(displayUserID)
                }
                if let names = user.userDetails?.lazy.flatMap({ [$0.name, $0.username] }).compacted() {
                    keywords.append(contentsOf: Set(names))
                }

                attributeSet.keywords = keywords

                return attributeSet
            }

            return nil
        }
    }
}

#endif
