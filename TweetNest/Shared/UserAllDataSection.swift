//
//  UserAllDataSection.swift
//  UserAllDataSection
//
//  Created by Jaehong Kang on 2021/08/01.
//

import SwiftUI
import TweetNestKit

struct UserAllDataSection: View {
    let user: User

    @FetchRequest
    private var userDatas: FetchedResults<UserData>

    var body: some View {
        Section("All Data") {
            ForEach(userDatas) { userData in
                NavigationLink {
                    List {
                        UserProfileSection(userData: userData)
                    }
                    .navigationTitle(userData.creationDate?.formatted(date: .abbreviated, time: .standard) ?? userData.objectID.description)
                } label: {
                    Text(userData.creationDate?.formatted(date: .abbreviated, time: .standard) ?? userData.objectID.description)
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
