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
    var previousUserDetail: UserDetail?
    @ObservedObject var currentUserDetail: UserDetail
    @Binding var diffKeyPath: KeyPath<UserDetail, [String]?>
    @Binding var searchQuery: String

    var previousUserIDs: OrderedSet<String> {
        OrderedSet(previousUserDetail?[keyPath: diffKeyPath] ?? [])
    }

    var currentUserIDs: OrderedSet<String>  {
        OrderedSet(currentUserDetail[keyPath: diffKeyPath] ?? [])
    }

    var appendedUserIDs: OrderedSet<String> {
        currentUserIDs.subtracting(previousUserIDs)
    }

    var removedUserIDs: OrderedSet<String> {
        previousUserIDs.subtracting(currentUserIDs)
    }

    var body: some View {
        if appendedUserIDs.isEmpty == false || removedUserIDs.isEmpty == false {
            Section {
                UserRows(userIDs: appendedUserIDs, searchQuery: $searchQuery) {
                    Image(systemName: "person.badge.plus")
                        .foregroundColor(.green)
                }

                UserRows(userIDs: removedUserIDs, searchQuery: $searchQuery) {
                    Image(systemName: "person.badge.minus")
                        .foregroundColor(.red)
                }
            } header: {
                Text(verbatim: currentUserDetail.creationDate?.formatted(date: .abbreviated, time: .standard) ?? currentUserDetail.objectID.description)
            }
            #if os(watchOS)
            .labelStyle(TweetNestWatchLabelStyle())
            #endif
        }
    }
}

//struct UsersDiffListSection_Previews: PreviewProvider {
//    static var previews: some View {
//        UsersDiffListSection()
//    }
//}
