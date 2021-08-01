//
//  AccountView.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/02/24.
//

import SwiftUI
import TweetNestKit

struct AccountView: View {
    let account: Account

    @State var showErrorAlert: Bool = false
    @State var error: Error? = nil

    var body: some View {
        Group {
            if let user = account.user {
                UserView(user: user)
            }
        }
        .toolbar(content: {
            ToolbarItem(placement: .automatic) {
                Button(action: refresh) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
            }
        })
        .alert("Error", isPresented: $showErrorAlert, presenting: error) { _ in

        } message: {
            $0.flatMap {
                Text($0.localizedDescription)
            }
        }
    }

    func refresh() {
        Task {
            do {
                try await account.updateUser()
            } catch {
                self.error = error
                showErrorAlert = true
            }
        }
    }
}

#if DEBUG
struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView(account: Account.preview)
    }
}
#endif
