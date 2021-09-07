//
//  Session+URL.swift
//  Session+URL
//
//  Created by Jaehong Kang on 2021/08/30.
//

import Foundation

extension Session {
    public func data(for request: URLRequest) async throws -> Data {
        let (data, response) = try await urlSession.data(for: request)
        guard
            let httpResponse = response as? HTTPURLResponse,
            (200..<300).contains(httpResponse.statusCode)
        else {
            throw SessionError.invalidServerResponse(response)
        }

        return data
    }
}
