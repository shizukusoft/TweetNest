//
//  FetchNewDataIntent.swift
//  TweetNestKit
//
//  Created by Jaehong Kang on 2022/08/09.
//

import AppIntents
import TweetNestKit

@available(iOSApplicationExtension 16.0, macOSApplicationExtension 13.0, watchOSApplicationExtension 9.0, *)
struct FetchNewDataIntent: AppIntent {
    public static let title: LocalizedStringResource = "Fetch New Data"
    public static var parameterSummary: some ParameterSummary {
        Summary("Fetch New Data")
    }

    public init() { }

    public func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
        return .result(value: try await Session.shared.fetchNewData(force: true))
    }
}
