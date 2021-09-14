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

    @FetchRequest private var symmetricDifferenceUserDetails: FetchedResults<UserDetail>
    @State private var symmetricDifferenceUserDetailsByUser: OrderedDictionary<String?, [UserDetail]>

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
                symmetricDifferenceUserDetails.nsPredicate = NSPredicate(format: "user.id in %@", newValue.sorted())
            }
            .onChange(of: Array(symmetricDifferenceUserDetails)) { newValue in
                symmetricDifferenceUserDetailsByUser = OrderedDictionary(grouping: newValue, by: { $0.user?.id })
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

        let symmetricDifferenceUserDetailsFetchRequest = UserDetail.fetchRequest()
        symmetricDifferenceUserDetailsFetchRequest.predicate = NSPredicate(format: "user.id in %@", userIDs)
        symmetricDifferenceUserDetailsFetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \UserDetail.user?.id, ascending: true),
            NSSortDescriptor(keyPath: \UserDetail.user?.creationDate, ascending: false),
            NSSortDescriptor(keyPath: \UserDetail.creationDate, ascending: false),
        ]
        symmetricDifferenceUserDetailsFetchRequest.relationshipKeyPathsForPrefetching = ["user"]

        self._symmetricDifferenceUserDetails = FetchRequest(
            fetchRequest: symmetricDifferenceUserDetailsFetchRequest
        )

        let symmetricDifferenceUserDetails = (try? Session.shared.persistentContainer.viewContext.fetch(symmetricDifferenceUserDetailsFetchRequest)) ?? []
        self._symmetricDifferenceUserDetailsByUser = State(initialValue: OrderedDictionary(grouping: symmetricDifferenceUserDetails, by: { $0.user?.id }))
    }

    @ViewBuilder
    private func userLabel<Icon>(userID: String, @ViewBuilder icon: () -> Icon) -> some View where Icon: View {
        let displayUserID = Int64(userID).flatMap { "#\($0.twnk_formatted())" } ?? "#\(userID)"

        let userDetails = symmetricDifferenceUserDetailsByUser[userID] ?? []

        if let latestUserDetail = userDetails.first {
            if
                searchQuery.isEmpty ||
                userDetails.contains(where: {
                    ($0.name?.localizedCaseInsensitiveContains(searchQuery) == true || $0.username?.localizedCaseInsensitiveContains(searchQuery) == true)
                })
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
