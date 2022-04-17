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
    let diffKeyPath: KeyPath<UserDetail, [String]?>
    let filteredUserIDsByNames: OrderedSet<String>?
    let searchQuery: String

    var previousUserDetail: UserDetail?
    @ObservedObject var userDetail: UserDetail

    var body: some View {
        let userIDs = OrderedSet(userDetail[keyPath: diffKeyPath] ?? [])
        let previousUserIDs = OrderedSet(previousUserDetail?[keyPath: diffKeyPath] ?? [])

        let appendedUserIDs = userIDs.subtracting(previousUserIDs)
        let removedUserIDs = previousUserIDs.subtracting(userIDs)

        let filteredAppendedUserIDs = searchQuery.isEmpty ? nil : OrderedSet(appendedUserIDs.filter { $0.localizedCaseInsensitiveContains(searchQuery) || $0.displayUserID.localizedCaseInsensitiveContains(searchQuery) || (filteredUserIDsByNames?.contains($0) ?? true) })
        let filteredRemovedUserIDs = searchQuery.isEmpty ? nil : OrderedSet(removedUserIDs.filter { $0.localizedCaseInsensitiveContains(searchQuery) || $0.displayUserID.localizedCaseInsensitiveContains(searchQuery) || (filteredUserIDsByNames?.contains($0) ?? true) })

        if appendedUserIDs.isEmpty == false || removedUserIDs.isEmpty == false {
            Section {
                UserRows(userIDs: filteredAppendedUserIDs ?? appendedUserIDs) {
                    Image(systemName: "person.badge.plus")
                        .foregroundColor(.green)
                }

                UserRows(userIDs: filteredRemovedUserIDs ?? removedUserIDs) {
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
