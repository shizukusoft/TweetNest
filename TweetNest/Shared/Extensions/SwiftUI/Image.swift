//
//  Image.swift
//  Image
//
//  Created by Jaehong Kang on 2021/08/01.
//

import SwiftUI

extension Image {
    init?(data: Data?) {
        guard let data = data else {
            return nil
        }

        #if os(macOS)
        guard let nsImage = NSImage(data: data) else {
            return nil
        }

        self.init(nsImage: nsImage)
        #else
        guard let uiImage = UIImage(data: data) else {
            return nil
        }

        self.init(uiImage: uiImage)
        #endif
    }
}
