//
//  AccountsFocusFilterIntent.swift
//  TweetNest App Intents Extension
//
//  Created by 강재홍 on 2022/08/12.
//

import AppIntents

struct AccountsFocusFilterIntent: SetFocusFilterIntent {
    static var title: LocalizedStringResource = "Filter accounts"
    static var description: LocalizedStringResource? = """
        Filter the accounts for Focus.
    """

    @Parameter(title: "Selected Accounts")
    var accounts: [AccountAppEntity]?

    var displayRepresentation: DisplayRepresentation {
        var titles: [LocalizedStringResource] = [], subtitles: [LocalizedStringResource] = []

        if let accounts = self.accounts {
            titles.append("Accounts")
            subtitles.append("\(accounts.count) accounts")
        }

        let title = LocalizedStringResource("Set \(titles, format: .list(type: .and))")
        let subtitle = LocalizedStringResource("\(subtitles, format: .list(type: .and))")

        return DisplayRepresentation(title: title, subtitle: subtitle)
    }

    var appContext: FocusFilterAppContext {
        let allowedUserIDs = accounts?.map { $0.userID }
        let notificationFilterPredicate = allowedAccountIDs.flatMap { NSPredicate(format: "SELF IN %@", $0) }
        return FocusFilterAppContext(notificationFilterPredicate: notificationFilterPredicate)
    }

    func perform() async throws -> some IntentResult {
        self.accounts
    }
}
