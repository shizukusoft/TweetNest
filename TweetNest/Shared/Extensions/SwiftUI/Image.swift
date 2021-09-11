//
//  Image.swift
//  Image
//
//  Created by Jaehong Kang on 2021/08/01.
//

import SwiftUI
import ImageIO

extension Image {
    init?(data: Data?) {
        guard let data = data else {
            return nil
        }

        guard let imageSource = CGImageSourceCreateWithData(
            data as CFData,
            nil
        ) else {
            return nil
        }

        guard let image = CGImageSourceCreateThumbnailAtIndex(
            imageSource,
            0,
            [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceShouldCache as String: true,
                kCGImageSourceShouldCacheImmediately as String: true,
                kCGImageSourceCreateThumbnailWithTransform as String: true,
            ] as CFDictionary
        ) else {
            return nil
        }

        let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any]

        let imageDPI = [imageProperties?[kCGImagePropertyDPIWidth], imageProperties?[kCGImagePropertyDPIHeight]].compactMap { ($0 as? NSNumber)?.doubleValue }.min()

        self.init(decorative: image, scale: imageDPI.flatMap { $0 / 72 } ?? 1.0)
    }
}
