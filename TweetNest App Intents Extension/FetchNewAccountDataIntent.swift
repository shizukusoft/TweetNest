//
//  FetchNewAccountDataIntent.swift
//  TweetNestKit
//
//  Created by Jaehong Kang on 2022/08/11.
//

import AppIntents
import TweetNestKit
import CoreData

@available(iOSApplicationExtension 16.0, macOSApplicationExtension 13.0, watchOSApplicationExtension 9.0, *)
struct FetchNewAccountDataIntent: AppIntent {
    public static let title: LocalizedStringResource = "Fetch New Data"
    public static var parameterSummary: some ParameterSummary {
        Summary("Fetch New Data for \(\.$accountEntity)")
    }

    var session: Session {
        .shared
    }

    @Parameter(title: "Account")
    var accountEntity: AccountAppEntity

    public init() { }

    public func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
        guard let managedObjectID = session.persistentContainer.persistentStoreCoordinator.managedObjectID(forURIRepresentation: accountEntity.managedObjectID) else {
            return .result(value: false)
        }

        let userDetailChanges = try await Session.shared.updateAccount(managedObjectID)

        return .result(value: userDetailChanges?.oldUserDetailObjectID != userDetailChanges?.newUserDetailObjectID)
    }
}
