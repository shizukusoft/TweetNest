//
//  ShareButton.swift
//  ShareButton
//
//  Created by Mina Her on 2021/08/08.
//

import AppKit
import SwiftUI

struct ShareButton: NSViewRepresentable {

    let items: [Any]

    init(items: [Any]) {
        self.items = items
    }

    init(item: Any) {
        self.items = [item]
    }

    init() {
        self.items = []
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> NSButton {
        let image = NSImage(systemSymbolName: "square.and.arrow.up", accessibilityDescription: nil)!
        let button = NSButton(image: image, target: context.coordinator, action: #selector(Coordinator.action(_:)))
        return button
    }

    func updateNSView(_ button: NSButton, context: Context) {
        button.setAccessibilityLabel(String(localized: "Share"))
        button.isEnabled = !items.isEmpty
    }
}

extension ShareButton {

    final class Coordinator {

        let shareButton: ShareButton

        init(_ shareButton: ShareButton) {
            self.shareButton = shareButton
        }

        @objc
        func action(_ sender: NSView) {
            let sharingServicePicker = NSSharingServicePicker(items: shareButton.items)
            sharingServicePicker.delegate = _SharingServicePickerDelegator.default
            sharingServicePicker.show(relativeTo: .zero, of: sender, preferredEdge: .minY)
        }
    }
}

extension ShareButton {

    private final class _SharingServicePickerDelegator: NSObject, NSSharingServicePickerDelegate {

        fileprivate static let `default` = _SharingServicePickerDelegator()
    }
}
