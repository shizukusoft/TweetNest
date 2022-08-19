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

#if os(macOS) || os(iOS)
private protocol WebAuthenticationSessionView {
    var webAuthenticationSession: ASWebAuthenticationSession { get }

    var window: ASPresentationAnchor? { get }
}
#endif

#if os(macOS)
extension WebAuthenticationView: NSViewRepresentable {
    class View: NSView, WebAuthenticationSessionView {
        let webAuthenticationSession: ASWebAuthenticationSession

        init(webAuthenticationSession: ASWebAuthenticationSession) {
            self.webAuthenticationSession = webAuthenticationSession

            super.init(frame: .zero)

            self.webAuthenticationSession.presentationContextProvider = self
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func draw(_ dirtyRect: NSRect) {
            NSColor.clear.setFill()
            dirtyRect.fill()
        }
    }

    func makeNSView(context: Context) -> View {
        let view = View(webAuthenticationSession: webAuthenticationSession)

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
    class View: UIView, WebAuthenticationSessionView {
        let webAuthenticationSession: ASWebAuthenticationSession

        init(webAuthenticationSession: ASWebAuthenticationSession) {
            self.webAuthenticationSession = webAuthenticationSession

            super.init(frame: .zero)

            self.backgroundColor = .clear
            self.webAuthenticationSession.presentationContextProvider = self
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    func makeUIView(context: Context) -> View {
        let view = View(webAuthenticationSession: webAuthenticationSession)

        return view
    }

    func updateUIView(_ uiView: View, context: Context) {
        uiView.start()
    }

    static func dismantleUIView(_ uiView: View, coordinator: ()) {
        uiView.cancel()
    }
}
#else
extension WebAuthenticationView: View {
    var body: some View {
        Rectangle()
            .foregroundColor(.clear)
            .frame(width: 0, height: 0)
            .onAppear {
                webAuthenticationSession.start()
            }
    }
}
#endif

#if os(macOS) || os(iOS)
extension WebAuthenticationView.View: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return window!
    }
}

extension WebAuthenticationSessionView {
    func start() {
        guard window != nil else {
            DispatchQueue.main.async { self.start() }
            return
        }

        webAuthenticationSession.start()
    }

    func cancel() {
        webAuthenticationSession.cancel()
    }
}
#endif
