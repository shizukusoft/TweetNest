//
//  SettingsAccountView.swift
//  SettingsAccountView
//
//  Created by Jaehong Kang on 2021/08/16.
//

import SwiftUI
import TweetNestKit

struct SettingsAccountView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var account: ManagedAccount

    @State var showError: Bool = false
    @State var error: TweetNestError?

    var body: some View {
        Form {
            Toggle(isOn: $account.preferences.fetchBlockingUsers) {
                Text("Fetch Blocking Users")
            }
            .onChange(of: account.preferences.fetchBlockingUsers) { _ in
                save()
            }

            Toggle(isOn: $account.preferences.fetchMutingUsers) {
                Text("Fetch Muting Users")
            }
            .onChange(of: account.preferences.fetchMutingUsers) { _ in
                save()
            }
        }
        .navigationTitle(
            Text(verbatim: account.users?.last?.userDetails?.last?.displayUsername ?? account.userID?.displayUserID ?? account.objectID.description)
        )
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .alert(isPresented: $showError, error: error)
    }

    func save() {
        do {
            try viewContext.save()
        } catch {
            self.error = TweetNestError(error)
            showError = true
        }
    }
}

struct SettingsAccountView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsAccountView(account: .preview)
    }
}
