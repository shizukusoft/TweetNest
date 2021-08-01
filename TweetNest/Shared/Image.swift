//
//  Image.swift
//  Image
//
//  Created by Jaehong Kang on 2021/08/01.
//

import SwiftUI

extension Image {
    init?(data: Data?) {
        #if os(macOS)
        guard let nsImage = data.flatMap({ NSImage(data: $0) }) else {
            return nil
        }

        self.init(nsImage: nsImage)
        #else
        guard let uiImage = data.flatMap({ UIImage(data: $0) }) else {
            return nil
        }

        self.init(uiImage: uiImage)
        #endif
    }
}
