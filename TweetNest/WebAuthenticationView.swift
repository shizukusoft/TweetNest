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
        let authenticationSession: ASWebAuthenticationSession

        init(authenticationSession: ASWebAuthenticationSession) {
            self.authenticationSession = authenticationSession

            super.init(frame: .zero)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    let url: URL
    let callbackURLScheme: String?

    @Binding var callbackURLResult: Result<URL, Swift.Error>?

    func makeUIView(context: Context) -> View {
        let view = View(authenticationSession: ASWebAuthenticationSession(url: url, callbackURLScheme: callbackURLScheme) { (url, error) in
            if let error = error {
                callbackURLResult = .failure(error)
            } else {
                callbackURLResult = .success(url!)
            }
        })
        view.frame = CGRect.zero

        return view
    }

    func updateUIView(_ uiView: View, context: Context) {
        uiView.authenticationSession.start()
    }

    static func dismantleUIView(_ uiView: View, coordinator: ()) {
        uiView.authenticationSession.cancel()
    }
}

extension WebAuthenticationView.View: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return window!
    }
}
