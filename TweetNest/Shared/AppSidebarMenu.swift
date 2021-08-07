//
//  AppSidebarMenu.swift
//  AppSidebarMenu
//
//  Created by Jaehong Kang on 2021/08/04.
//

import SwiftUI
import TweetNestKit
import AuthenticationServices

struct AppSidebarMenu: View {
    @State var webAuthenticationSession: ASWebAuthenticationSession?
    @State var isAddingAccount: Bool = false

    @State var showAccountsEditor: Bool = false

    @State var showErrorAlert: Bool = false
    @State var error: Error? = nil

    var body: some View {
        ZStack {
            Menu {
                Button(action: addAccount) {
                    Label("Add Account", systemImage: "plus")
                }
                .disabled(isAddingAccount)

                Button {
                    showAccountsEditor.toggle()
                } label: {
                    Text("Edit Accounts")
                }
            } label: {
                Label("Menu", systemImage: "ellipsis.circle")
                    .labelStyle(.iconOnly)
            }

            if let webAuthenticationSession = webAuthenticationSession {
                WebAuthenticationView(webAuthenticationSession: webAuthenticationSession)
                    .zIndex(1.0)
            }
        }
        .alertError(isPresented: $showErrorAlert, error: $error)
        .sheet(isPresented: $showAccountsEditor) {
            NavigationView {
                AccountsEditorView()
                    .toolbar {
                        ToolbarItemGroup(placement: .cancellationAction) {
                            Button("Cancel", role: .cancel) {
                                showAccountsEditor.toggle()
                            }
                        }
                    }
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

struct AppSidebarMenu_Previews: PreviewProvider {
    static var previews: some View {
        AppSidebarMenu()
    }
}
