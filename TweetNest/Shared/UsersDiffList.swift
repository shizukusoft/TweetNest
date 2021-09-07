//
//  UsersDiffList.swift
//  UsersDiffList
//
//  Created by Jaehong Kang on 2021/08/09.
//

import SwiftUI
import TweetNestKit
import OrderedCollections

struct UsersDiffList: View {
    @ObservedObject var user: User
    @State var diffKeyPath: KeyPath<UserDetail, [String]?>
    @State var title: Text

    @State private var searchQuery: String = ""
    
    @ViewBuilder private var usersDiffList: some View {
        List {
            let sortedUserDetails = user.sortedUserDetails ?? OrderedSet()
            
            ForEach(sortedUserDetails.reversed()) { userDetail in
                let previousUserDetailIndex = (sortedUserDetails.firstIndex(of: userDetail) ?? 0) - 1
                let previousUserDetail = (sortedUserDetails.startIndex..<sortedUserDetails.endIndex).contains(previousUserDetailIndex) ? sortedUserDetails[previousUserDetailIndex] : nil

                UsersDiffListSection(previousUserDetail: previousUserDetail, currentUserDetail: userDetail, diffKeyPath: $diffKeyPath, searchQuery: $searchQuery)
            }
        }
        .searchable(text: $searchQuery)
    }

    var body: some View {
        #if os(macOS)
        NavigationView {
            usersDiffList
                .listStyle(.plain)
                .navigationTitle(title)
        }
        .navigationViewStyle(.columns)
        #else
        usersDiffList
            .navigationTitle(title)
        #endif
    }
}

//struct UsersDiffList_Previews: PreviewProvider {
//    static var previews: some View {
//        UsersDiffList()
//    }
//}
