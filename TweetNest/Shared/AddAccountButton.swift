//
//  AddAccountButton.swift
//  AddAccountButton
//
//  Created by Jaehong Kang on 2021/07/31.
//

import SwiftUI
import TweetNestKit
import AuthenticationServices

struct AddAccountButton: View {
    @State var webAuthenticationSession: ASWebAuthenticationSession?
    @State var isAddingAccount: Bool = false
    @State var showErrorAlert: Bool = false
    @State var error: Error? = nil

    var body: some View {
        ZStack {
            Button(action: addAccount) {
                Label("Add Account", systemImage: "plus")
            }
            .disabled(isAddingAccount)

            if let webAuthenticationSession = webAuthenticationSession {
                WebAuthenticationView(webAuthenticationSession: webAuthenticationSession)
                    .zIndex(1.0)
            }
        }
        .alert("Error", isPresented: $showErrorAlert, presenting: error) { _ in

        } message: {
            $0.flatMap {
                Text($0.localizedDescription)
            }
        }
    }

    private func addAccount() {
        withAnimation {
            isAddingAccount = true
        }

        Task {
            do {
                try await Session.shared.authorizeNewAccount { webAuthenticationSession in
                    self.webAuthenticationSession = webAuthenticationSession
                }

                webAuthenticationSession = nil

                withAnimation {
                    isAddingAccount = false
                }
            } catch {
                withAnimation {
                    webAuthenticationSession = nil
                    self.error = error
                    showErrorAlert = true
                    isAddingAccount = false
                }
            }
        }
    }
}

#if DEBUG
struct AddAccountButton_Previews: PreviewProvider {
    static var previews: some View {
        AddAccountButton()
    }
}
#endif
