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
    var previousUserData: UserData?
    @ObservedObject var currentUserData: UserData
    @Binding var diffKeyPath: KeyPath<UserData, [String]?>

    var previousUserIDs: OrderedSet<String> {
        OrderedSet(previousUserData?[keyPath: diffKeyPath] ?? [])
    }

    var currentUserIDs: OrderedSet<String>  {
        OrderedSet(currentUserData[keyPath: diffKeyPath] ?? [])
    }

    var appendedUserIDs: OrderedSet<String> {
        currentUserIDs.subtracting(previousUserIDs)
    }

    var removedUserIDs: OrderedSet<String> {
        previousUserIDs.subtracting(currentUserIDs)
    }

    var body: some View {
        if appendedUserIDs.isEmpty == false || removedUserIDs.isEmpty == false {
            Section(currentUserData.creationDate?.formatted(date: .abbreviated, time: .standard) ?? currentUserData.objectID.description) {
                ForEach(appendedUserIDs, id: \.self) { userID in
                    Label {
                        UserRow(userID: userID)
                    } icon: {
                        Image(systemName: "person.badge.plus")
                            .foregroundColor(.green)
                    }
                }

                ForEach(removedUserIDs, id: \.self) { userID in
                    Label {
                        UserRow(userID: userID)
                    } icon: {
                        Image(systemName: "person.badge.minus")
                            .foregroundColor(.red)
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
