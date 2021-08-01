//
//  AppSidebarNavigation.swift
//  AppSidebarNavigation
//
//  Created by Jaehong Kang on 2021/07/31.
//

import SwiftUI
import TweetNestKit

struct AppSidebarNavigation: View {
    enum NavigationItem: Hashable {
        case account(Account)
        case followings(Account)
        case followers(Account)
    }

    @State private var navigationItemSelection: NavigationItem? = nil

    var body: some View {
        NavigationView {
            List {
                AccountsSection(navigationItemSelection: $navigationItemSelection)
            }
            .listStyle(.sidebar)
            .navigationTitle(Text("TweetNest"))
            .toolbar {
                #if os(iOS)
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    EditButton()
                }
                #endif

                ToolbarItemGroup(placement: .primaryAction) {
                    AddAccountButton()
                }
            }
        }
    }
}

struct AppSidebarNavigation_Previews: PreviewProvider {
    static var previews: some View {
        AppSidebarNavigation()
            .environment(\.managedObjectContext, Session.preview.container.viewContext)
    }
}
