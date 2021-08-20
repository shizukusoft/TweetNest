//
//  UserAllDataSection.swift
//  UserAllDataSection
//
//  Created by Jaehong Kang on 2021/08/01.
//

import SwiftUI
import TweetNestKit

struct UserAllDataSection: View {
    @Environment(\.account) var account: Account?
    @ObservedObject var user: User

    @FetchRequest
    private var userDetails: FetchedResults<UserDetail>

    var body: some View {
        Section(Text("All Data")) {
            ForEach(userDetails) { userDetail in
                NavigationLink(
                    Text(userDetail.creationDate?.formatted(date: .abbreviated, time: .standard) ?? userDetail.objectID.description))
                {
                    UserDetailView(userDetail: userDetail)
                        .navigationTitle(
                            Text(userDetail.creationDate?.formatted(date: .abbreviated, time: .standard) ?? userDetail.objectID.description)
                            .accessibilityLabel(Text(userDetail.creationDate?.formatted(date: .complete, time: .standard) ?? userDetail.objectID.description))
                        )
                        .environment(\.account, account)
                }
            }
        }
    }

    init(user: User) {
        self.user = user
        self._userDetails = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \User.creationDate, ascending: false)],
            predicate: NSPredicate(format: "user == %@", user),
            animation: .default
        )
    }
}

#if DEBUG
struct UserAllDataSection_Previews: PreviewProvider {
    static var previews: some View {
        UserAllDataSection(user: Account.preview.user!)
    }
}
#endif
