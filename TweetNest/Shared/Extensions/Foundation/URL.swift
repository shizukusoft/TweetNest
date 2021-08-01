//
//  URL.swift
//  URL
//
//  Created by Jaehong Kang on 2021/08/02.
//

import Foundation

extension URL: Identifiable {
    public var id: String {
        absoluteString
    }
}
