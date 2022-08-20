//
//  Pasteboard.swift
//  TweetNest
//
//  Created by Mina Her on 2022/05/21.
//

import CoreGraphics
import Foundation

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

protocol _PasteboardProtocol {

    /// The system-wide general pasteboard.
    ///
    static var general: Self {get}

    /// The `CGImage` object of the first pasteboard item.
    ///
    /// Setting this property replaces all current items in the
    /// pasteboard with the new item. If the first item has no value
    /// of the indicated type, `nil` is returned.
    ///
    /// - Note:
    ///   A `CGImage` object is transformed to `NSImage` object or
    ///   `UIImage` object before put it in.
    ///
    var image: CGImage? {get set}

    /// The `String` value of the first pasteboard item.
    ///
    /// Setting this property replaces all current items in the
    /// pasteboard with the new item. If the first item has no value
    /// of the indicated type, `nil` is returned.
    ///
    var string: String? {get set}

    /// The `URL` value of the first pasteboard item.
    ///
    /// Setting this property replaces all current items in the
    /// pasteboard with the new item. If the first item has no value
    /// of the indicated type, `nil` is returned.
    ///
    var url: URL? {get set}
}

#if canImport(AppKit) || (canImport(UIKit) && os(iOS))
/// A cross-platform pasteboard interface.
///
final class Pasteboard: _PasteboardProtocol {

    static var general: Pasteboard {
        .init(.general)
    }
    #if canImport(AppKit)

    var image: CGImage? {
        get {
            if
                let nsImages = _nsPasteboard.readObjects(forClasses: [NSImage.self]) as? [NSImage],
                let nsImage = nsImages.first
            {
                return nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil)
            }
            return nil
        }
        set {
            _nsPasteboard.clearContents()
            if let newValue = newValue {
                _nsPasteboard.writeObjects([NSImage(cgImage: newValue, size: .zero)])
            }
        }
    }

    var string: String? {
        get {
            _nsPasteboard.string(forType: .string)
        }
        set {
            _nsPasteboard.clearContents()
            if let newValue = newValue {
                _nsPasteboard.setString(newValue, forType: .string)
            }
        }
    }

    var url: URL? {
        get {
            if let string = _nsPasteboard.string(forType: .fileURL) ?? _nsPasteboard.string(forType: .URL) {
                return .init(string: string)
            }
            return nil
        }
        set {
            _nsPasteboard.clearContents()
            if let newValue = newValue {
                if newValue.isFileURL {
                    _nsPasteboard.setString(newValue.standardizedFileURL.absoluteString, forType: .fileURL)
                } else {
                    _nsPasteboard.setString(newValue.standardized.absoluteString, forType: .URL)
                }
            }
        }
    }

    private let _nsPasteboard: NSPasteboard

    private init(_ nsPasteboard: NSPasteboard) {
        _nsPasteboard = nsPasteboard
    }
    #elseif canImport(UIKit) && os(iOS)

    var image: CGImage? {
        get {
            _uiPasteboard.image?.cgImage
        }
        set {
            if let newValue = newValue {
                _uiPasteboard.image = .init(cgImage: newValue)
            } else {
                _uiPasteboard.image = nil
            }
        }
    }

    var string: String? {
        get {
            _uiPasteboard.string
        }
        set {
            _uiPasteboard.string = newValue
        }
    }

    var url: URL? {
        get {
            _uiPasteboard.url
        }
        set {
            _uiPasteboard.url = newValue
        }
    }

    private let _uiPasteboard: UIPasteboard

    private init(_ uiPasteboard: UIPasteboard) {
        _uiPasteboard = uiPasteboard
    }
    #endif
}
#endif
