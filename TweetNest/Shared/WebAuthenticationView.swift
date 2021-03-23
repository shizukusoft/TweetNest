//
//  WebAuthenticationView.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/02/24.
//

import SwiftUI
import AuthenticationServices

struct WebAuthenticationView {
    let webAuthenticationSession: ASWebAuthenticationSession
}

#if os(macOS)
extension WebAuthenticationView: NSViewRepresentable {
    class View: NSView {
        private let authenticationSession: ASWebAuthenticationSession

        init(authenticationSession: ASWebAuthenticationSession) {
            self.authenticationSession = authenticationSession

            super.init(frame: .zero)

            self.authenticationSession.presentationContextProvider = self
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func draw(_ dirtyRect: NSRect) {
            NSColor.clear.setFill()
            dirtyRect.fill()
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

    func makeNSView(context: Context) -> View {
        webAuthenticationSession.prefersEphemeralWebBrowserSession = true

        let view = View(authenticationSession: webAuthenticationSession)

        return view
    }

    func updateNSView(_ nsView: View, context: Context) {
        nsView.start()
    }

    static func dismantleNSView(_ nsView: View, coordinator: ()) {
        nsView.cancel()
    }
}
#elseif os(iOS)
extension WebAuthenticationView: UIViewRepresentable {
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

    func makeUIView(context: Context) -> View {
        webAuthenticationSession.prefersEphemeralWebBrowserSession = true

        let view = View(authenticationSession: webAuthenticationSession)

        return view
    }

    func updateUIView(_ uiView: View, context: Context) {
        uiView.start()
    }

    static func dismantleUIView(_ uiView: View, coordinator: ()) {
        uiView.cancel()
    }
}
#endif

extension WebAuthenticationView.View: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return window!
    }
}
