//
//  UsersDiffListSection.swift
//  TweetNest
//
//  Created by 강재홍 on 2022/03/20.
//

import SwiftUI
import OrderedCollections
import TweetNestKit

struct UsersDiffListSection: View {
    let diffKeyPath: KeyPath<ManagedUserDetail, [String]?>
    let searchQuery: String

    var previousUserDetail: ManagedUserDetail?
    @ObservedObject var userDetail: ManagedUserDetail

    var body: some View {
        let userIDs = OrderedSet(userDetail[keyPath: diffKeyPath] ?? [])
        let previousUserIDs = OrderedSet(previousUserDetail?[keyPath: diffKeyPath] ?? [])

        let appendedUserIDs = userIDs.subtracting(previousUserIDs)
        let removedUserIDs = previousUserIDs.subtracting(userIDs)

        if appendedUserIDs.isEmpty == false || removedUserIDs.isEmpty == false {
            Section {
                UserRows(userIDs: appendedUserIDs, searchQuery: searchQuery) {
                    Image(systemName: "person.badge.plus")
                        .foregroundColor(.green)
                }

                UserRows(userIDs: removedUserIDs, searchQuery: searchQuery) {
                    Image(systemName: "person.badge.minus")
                        .foregroundColor(.red)
                }
            } header: {
                HStack {
                    Group {
                        if let creationDate = userDetail.creationDate {
                            DateText(date: creationDate)
                        } else {
                            Text(verbatim: userDetail.objectID.description)
                        }
                    }

                    Spacer()

                    HStack {
                        if appendedUserIDs.count > 0 {
                            Text(verbatim: "+\(appendedUserIDs.count.formatted())")
                                .foregroundColor(.green)
                        }

                        if removedUserIDs.count > 0 {
                            Text(verbatim: "-\(removedUserIDs.count.formatted())")
                                .foregroundColor(.red)
                        }

                        Text(userIDs.count.formatted())
                    }
                }
            }
        }
    }
}

//struct UsersDiffListSection_Previews: PreviewProvider {
//    static var previews: some View {
//        UsersDiffListSection()
//    }
//}
