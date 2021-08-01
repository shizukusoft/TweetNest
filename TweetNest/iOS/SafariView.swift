//
//  SafariView.swift
//  SafariView
//
//  Created by Jaehong Kang on 2021/08/02.
//

import SwiftUI
import UIKit
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    typealias UIViewControllerType = SFSafariViewController

    let url: URL
    let entersReaderIfAvailable: Bool = false
    let barCollapsingEnabled: Bool = true

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIViewControllerType {
        let configuration = SFSafariViewController.Configuration()
        configuration.entersReaderIfAvailable = entersReaderIfAvailable
        configuration.barCollapsingEnabled = barCollapsingEnabled

        let safariViewController = SFSafariViewController(url: url, configuration: configuration)
        safariViewController.delegate = context.coordinator

        return safariViewController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {

    }

    class Coordinator: NSObject, SFSafariViewControllerDelegate {
        var safariView: SafariView

        init(_ safariView: SafariView) {
            self.safariView = safariView
        }
    }
}
