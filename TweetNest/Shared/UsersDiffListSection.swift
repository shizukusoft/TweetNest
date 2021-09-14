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

    @Binding var searchQuery: String

    @SectionedFetchRequest private var symmetricDifferenceUserDetailsByUser: SectionedFetchResults<String?, UserDetail>

    var appendedUserIDs: OrderedSet<String> {
        userIDs.subtracting(previousUserIDs)
    }

    var removedUserIDs: OrderedSet<String> {
        previousUserIDs.subtracting(userIDs)
    }

    var symmetricDifferenceUserIDs: OrderedSet<String> {
        userIDs.symmetricDifference(previousUserIDs)
    }

    var body: some View {
        if appendedUserIDs.isEmpty == false || removedUserIDs.isEmpty == false {
            Section {
                ForEach(appendedUserIDs, id: \.self) { userID in
                    userLabel(userID: userID) {
                        Image(systemName: "person.badge.plus")
                            .foregroundColor(.green)
                    }
                    .id(userID)
                }
                .id(appendedUserIDs)

                ForEach(removedUserIDs, id: \.self) { userID in
                    userLabel(userID: userID) {
                        Image(systemName: "person.badge.minus")
                            .foregroundColor(.red)
                    }
                    .id(userID)
                }
                .id(removedUserIDs)
            } header: {
                header
            }
            .onChange(of: symmetricDifferenceUserIDs) { newValue in
                symmetricDifferenceUserDetailsByUser.nsPredicate = NSPredicate(format: "user.id in %@", newValue.sorted())
            }
        }
    }

    init(
        header: Text,
        userIDs: OrderedSet<String>,
        previousUserIDs: OrderedSet<String>,
        searchQuery: Binding<String>
    ) {
        self.header = header
        self.userIDs = userIDs
        self.previousUserIDs = previousUserIDs
        self._searchQuery = searchQuery

        let userIDs = userIDs.symmetricDifference(previousUserIDs).sorted()

        self._symmetricDifferenceUserDetailsByUser = SectionedFetchRequest(
            fetchRequest: {
                let fetchRequest = UserDetail.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "user.id in %@", userIDs)
                fetchRequest.sortDescriptors = [
                    NSSortDescriptor(keyPath: \UserDetail.user?.id, ascending: true),
                    NSSortDescriptor(keyPath: \UserDetail.user?.creationDate, ascending: false),
                    NSSortDescriptor(keyPath: \UserDetail.creationDate, ascending: false),
                ]
                fetchRequest.propertiesToFetch = ["name", "username", "profileImageURL", "user"]
                fetchRequest.returnsDistinctResults = true

                return fetchRequest
            }(),
            sectionIdentifier: \.user?.id
        )
    }

    @ViewBuilder
    private func userLabel<Icon>(userID: String, @ViewBuilder icon: () -> Icon) -> some View where Icon: View {
        let displayUserID = Int64(userID).flatMap { "#\($0.twnk_formatted())" } ?? "#\(userID)"
        let userDetailsSection = symmetricDifferenceUserDetailsByUser.first(where: { $0.id == userID })

        if let latestUserDetail = userDetailsSection?.first {
            if
                searchQuery.isEmpty ||
                userDetailsSection?.contains(where: {
                    ($0.name?.localizedCaseInsensitiveContains(searchQuery) == true || $0.username?.localizedCaseInsensitiveContains(searchQuery) == true)
                }) == true
            {
                Label(
                    title: {
                        UserLabel(userDetail: latestUserDetail, displayUserID: displayUserID)
                            #if os(watchOS)
                            .labelStyle(.titleOnly)
                            #endif
                    },
                    icon: icon
                )
                .accessibilityLabel(Text(verbatim: latestUserDetail.name ?? displayUserID))
            }
        } else {
            if searchQuery.isEmpty || displayUserID.contains(searchQuery) {
                Label(
                    title: {
                        UserLabel(displayUserID: displayUserID)
                    },
                    icon: icon
                )
            }
        }
    }
}

//struct UsersDiffListSection_Previews: PreviewProvider {
//    static var previews: some View {
//        UsersDiffListSection()
//    }
//}
