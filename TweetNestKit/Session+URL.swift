//
//  Session+URL.swift
//  Session+URL
//
//  Created by Jaehong Kang on 2021/08/30.
//

import Foundation

extension Session {
    nonisolated func download(from url: URL) async throws -> URL {
        let (url, response) = try await urlSession.download(from: url)
        guard
            let httpResponse = response as? HTTPURLResponse,
            (200..<300).contains(httpResponse.statusCode)
        else {
            throw SessionError.invalidServerResponse(response)
        }

        return url
    }
}
