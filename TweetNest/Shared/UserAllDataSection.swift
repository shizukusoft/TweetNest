//
//  UserAllDataSection.swift
//  UserAllDataSection
//
//  Created by Jaehong Kang on 2021/08/01.
//

import SwiftUI
import TweetNestKit

struct UserAllDataSection: View {
    @ObservedObject var user: User

    @FetchRequest
    private var userDatas: FetchedResults<UserData>

    var body: some View {
        Section(Text("All Data")) {
            ForEach(userDatas) { userData in
                NavigationLink(
                    Text(userData.creationDate?.formatted(date: .abbreviated, time: .standard) ?? userData.objectID.description))
                {
                    UserDataView(userData: userData)
                    .navigationTitle(
                        Text(userData.creationDate?.formatted(date: .abbreviated, time: .standard) ?? userData.objectID.description)
                        .accessibilityLabel(Text(userData.creationDate?.formatted(date: .complete, time: .standard) ?? userData.objectID.description))
                    )
                }
            }
        }
    }

    init(user: User) {
        self.user = user
        self._userDatas = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \User.creationDate, ascending: false)],
            predicate: NSPredicate(format: "user.id == %@", user.id),
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
