//
//  ShareView.swift
//  ShareView
//
//  Created by Mina Her on 2021/08/08.
//

import SwiftUI
import UIKit

struct ShareView: UIViewControllerRepresentable {

    let items: [Any]

    @Environment(\.dismiss)
    private var dismiss

    init(items: [Any]) {
        self.items = items
    }

    init(item: Any) {
        self.items = [item]
    }

    init() {
        self.items = []
    }

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let viewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        viewController.completionWithItemsHandler = {
            (activityType, completed, returnedItems, activityError) in
            dismiss()
        }
        return viewController
    }

    func updateUIViewController(_ viewController: UIActivityViewController, context: Context) {
    }
}
