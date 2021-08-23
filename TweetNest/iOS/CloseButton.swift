//
//  CloseButton.swift
//  CloseButton
//
//  Created by Mina Her on 2021/08/23.
//

import SwiftUI
import UIKit

struct CloseButton: UIViewRepresentable {

    private let _action: () -> Void

    init(action: @escaping () -> Void) {
        _action = action
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIButton {
        let button = UIButton(type: .close)
        button.addTarget(context.coordinator, action: #selector(Coordinator.action(_:)), for: .touchUpInside)
        return button
    }

    func updateUIView(_ button: UIButton, context: Context) {
        button.accessibilityLabel = String(localized: "Close")
    }
}

extension CloseButton {

    final class Coordinator {

        let closeButton: CloseButton

        init(_ closeButton: CloseButton) {
            self.closeButton = closeButton
        }

        @objc
        func action(_ sender: UIView) {
            closeButton._action()
        }
    }
}
