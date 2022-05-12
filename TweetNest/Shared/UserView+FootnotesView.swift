//
//  UserView+FootnotesView.swift
//  TweetNest
//
//  Created by 강재홍 on 2022/04/17.
//

import SwiftUI
import TweetNestKit

extension UserView {
    struct FootnotesView: View {
        let userID: String
        let user: ManagedUser?


        var body: some View {
            VStack(alignment: .leading) {
                Text(userID.displayUserID)
                if let user = user {
                    UpdatesText(user: user)
                }
            }
            #if os(macOS)
            .font(.footnote)
            .foregroundColor(.secondary)
            #endif
        }
    }
}

extension UserView.FootnotesView {
    private struct UpdatesText: View {
        @ObservedObject var user: ManagedUser

        var body: some View {
            if let lastUpdateStartDate = user.lastUpdateStartDate, let lastUpdateEndDate = user.lastUpdateEndDate {
                Group {
                    if lastUpdateStartDate > lastUpdateEndDate && lastUpdateStartDate.addingTimeInterval(60) >= Date() {
                        Text("Updating…")
                    } else {
                        Text("Updated \(lastUpdateEndDate, style: .relative) ago")
                    }
                }
                .accessibilityAddTraits(.updatesFrequently)
            }
        }
    }
}
