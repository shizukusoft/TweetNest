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
    @State var diffKeyPath: KeyPath<UserData, [String]?>

    var body: some View {
        let sortedUserDatas = user.sortedUserDatas ?? OrderedSet()

        List {
            ForEach(sortedUserDatas.reversed()) { userData in
                let previousUserDataIndex = (sortedUserDatas.firstIndex(of: userData) ?? 0) - 1
                let previousUserData = (sortedUserDatas.startIndex..<sortedUserDatas.endIndex).contains(previousUserDataIndex) ? sortedUserDatas[previousUserDataIndex] : nil

                UsersDiffListSection(previousUserData: previousUserData, currentUserData: userData, diffKeyPath: $diffKeyPath)
            }
        }
    }
}

//struct UsersDiffList_Previews: PreviewProvider {
//    static var previews: some View {
//        UsersDiffList()
//    }
//}
