//
//  AppSidebarNavigationAccountsRowContent.swift
//  AppSidebarNavigationAccountsRowContent
//
//  Created by Jaehong Kang on 2021/09/15.
//

import SwiftUI
import TweetNestKit

struct AppSidebarNavigationAccountsRowContent: View {
    @State var navigationItemSelection: AppSidebarNavigationItem?

    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\.preferringSortOrder, order: .forward),
            SortDescriptor(\.creationDate, order: .reverse),
        ],
        animation: .default)
    private var accounts: FetchedResults<Account>

    var body: some View {
        ForEach(accounts) { account in
            AppSidebarAccountsSection(account: account, navigationItemSelection: $navigationItemSelection)
        }
    }
}

struct AppSidebarNavigationAccountsRowContent_Previews: PreviewProvider {
    static var previews: some View {
        AppSidebarNavigationAccountsRowContent()
    }
}
