//
//  URL.swift
//  URL
//
//  Created by Jaehong Kang on 2021/08/02.
//

import Foundation

extension URL {

    var simplifiedString: String {
        let standardizedURL = isFileURL ? standardizedFileURL : standardized
        guard
            var components = URLComponents(url: standardizedURL, resolvingAgainstBaseURL: true),
            let scheme = components.scheme
        else {
            return standardizedURL.absoluteString
        }
        if scheme == "http" {
            components.scheme = nil
            if components.port == 80 {
                components.port = nil
            }
        } else if scheme == "https" {
            components.scheme = nil
            if components.port == 443 {
                components.port = nil
            }
        }
        components.user = nil
        components.password = nil
        if let host = components.host, host.hasPrefix("www.") {
            components.host = .init(host[host.index(host.startIndex, offsetBy: 4)...])
        }
        if components.path == "/" {
            components.path = ""
        }
        components.query = nil
        components.fragment = nil
        guard let string = components.string
        else {
            return standardizedURL.absoluteString
        }
        return string.hasPrefix("//") ? .init(string.dropFirst(2)) : string
    }
}

extension URL: Identifiable {
    public var id: String {
        absoluteString
    }
}
