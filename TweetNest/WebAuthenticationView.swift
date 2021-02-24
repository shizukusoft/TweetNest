//
//  WebAuthenticationView.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/02/24.
//

import SwiftUI
import AuthenticationServices

struct WebAuthenticationView: UIViewRepresentable {
    class View: UIView {
        private let authenticationSession: ASWebAuthenticationSession

        init(authenticationSession: ASWebAuthenticationSession) {
            self.authenticationSession = authenticationSession

            super.init(frame: .zero)

            self.backgroundColor = .clear
            self.authenticationSession.presentationContextProvider = self
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func start() {
            guard window != nil else {
                DispatchQueue.main.async { self.start() }
                return
            }

            authenticationSession.start()
        }

        func cancel() {
            authenticationSession.cancel()
        }
    }

    let url: URL
    let callbackURLScheme: String?

    @Binding var callbackURLResult: Result<URL, Swift.Error>?

    func makeUIView(context: Context) -> View {
        let view = View(authenticationSession: ASWebAuthenticationSession(url: url, callbackURLScheme: callbackURLScheme) { (url, error) in
            if let error = error {
                DispatchQueue.main.async {
                    callbackURLResult = .failure(error)
                }
            } else {
                DispatchQueue.main.async {
                    callbackURLResult = .success(url!)
                }
            }
        })
        view.frame = CGRect.zero

        return view
    }

    func updateUIView(_ uiView: View, context: Context) {
        uiView.start()
    }

    static func dismantleUIView(_ uiView: View, coordinator: ()) {
        uiView.cancel()
    }
}

extension WebAuthenticationView.View: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return window!
    }
}
