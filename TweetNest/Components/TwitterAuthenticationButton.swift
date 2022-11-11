//
//  TwitterAuthenticationButton.swift
//  TweetNest
//
//  Created by 강재홍 on 2022/08/19.
//

import SwiftUI
import CoreData
import AuthenticationServices
import UnifiedLogging

struct TwitterAuthenticationButton<Label: View>: View {
    let managedAccountObjectID: NSManagedObjectID?
    let role: ButtonRole?
    let label: Label

    @State private var webAuthenticationSession: ASWebAuthenticationSession?
    @State private var isAddingAccount: Bool = false

    @State private var showErrorAlert: Bool = false
    @State private var error: TweetNestError?

    init(managedAccountObjectID: NSManagedObjectID? = nil, role: ButtonRole? = nil, @ViewBuilder label: () -> Label) {
        self.managedAccountObjectID = managedAccountObjectID
        self.role = role
        self.label = label()
    }

    var body: some View {
        Button(role: role, action: addAccount) {
            label
        }
        .disabled(isAddingAccount)
        .background(alignment: .center) {
            if let webAuthenticationSession = webAuthenticationSession {
                WebAuthenticationView(webAuthenticationSession: webAuthenticationSession)
            }
        }
        .alert(isPresented: $showErrorAlert, error: error)
    }

    private func addAccount() {
        withAnimation {
            isAddingAccount = true
        }

        Task {
            defer {
                withAnimation {
                    webAuthenticationSession = nil
                    isAddingAccount = false
                }
            }

            do {
                try await TweetNestApp.session.authenticateAccount(managedAccountObjectID: managedAccountObjectID) { webAuthenticationSession in
                    webAuthenticationSession.prefersEphemeralWebBrowserSession = true

                    self.webAuthenticationSession = webAuthenticationSession
                }
            } catch ASWebAuthenticationSessionError.canceledLogin {
                Logger().error("Error occurred: \(String(reflecting: ASWebAuthenticationSessionError.canceledLogin), privacy: .public)")
            } catch {
                withAnimation {
                    Logger().error("Error occurred: \(String(reflecting: error), privacy: .public)")
                    self.error = TweetNestError(error)
                    showErrorAlert = true
                }
            }
        }
    }
}
