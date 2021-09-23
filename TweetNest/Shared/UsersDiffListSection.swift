//
//  UsersDiffListSection.swift
//  UsersDiffListSection
//
//  Created by Jaehong Kang on 2021/08/09.
//

import SwiftUI
import TweetNestKit
import OrderedCollections

struct UsersDiffListSection: View {
    let header: Text

    let userIDs: OrderedSet<String>
    let previousUserIDs: OrderedSet<String>

    let searchQuery: String

    var appendedUserIDs: OrderedSet<String> {
        userIDs.subtracting(previousUserIDs)
    }

    var removedUserIDs: OrderedSet<String> {
        previousUserIDs.subtracting(userIDs)
    }

    var body: some View {
        if appendedUserIDs.isEmpty == false || removedUserIDs.isEmpty == false {
            Section {
                ForEach(appendedUserIDs, id: \.self) { userID in
                    Label {
                        UserRow(userID: userID, searchQuery: searchQuery)
                    } icon: {
                        Image(systemName: "person.badge.plus")
                            .foregroundColor(.green)
                    }
                }

                ForEach(removedUserIDs, id: \.self) { userID in
                    Label {
                        UserRow(userID: userID, searchQuery: searchQuery)
                    } icon: {
                        Image(systemName: "person.badge.minus")
                            .foregroundColor(.red)
                    }
                }
            } header: {
                header
            }
        }
    }
}

//struct UsersDiffListSection_Previews: PreviewProvider {
//    static var previews: some View {
//        UsersDiffListSection()
//    }
//}
