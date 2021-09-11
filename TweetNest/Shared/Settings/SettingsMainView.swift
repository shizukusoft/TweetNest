//
//  SettingsMainView.swift
//  SettingsMainView
//
//  Created by Jaehong Kang on 2021/08/16.
//

import SwiftUI
import CoreData
import TweetNestKit

enum SettingsNavigationItem: Hashable {
    case general
    case accounts
}

struct SettingsMainView: View {
    #if os(macOS)
    @State var selectedNavigationItem: SettingsNavigationItem = .general
    #else
    @State var selectedNavigationItem: SettingsNavigationItem? = nil
    #endif

    #if os(macOS)
    var body: some View {
        TabView(selection: $selectedNavigationItem) {
            SettingsGeneralView()
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }
                .tag(SettingsNavigationItem.general)

            SettingsAccountsView()
                .tabItem {
                    Label("Accounts", systemImage: "person.3")
                }
                .tag(SettingsNavigationItem.accounts)
        }
        .frame(minWidth: 600, minHeight: 300)
    }
    #else
    var body: some View {
        Form {
            Section {
                NavigationLink(
                    tag: SettingsNavigationItem.general,
                    selection: $selectedNavigationItem
                ) {
                    SettingsGeneralView()
                } label: {
                    Label("General", systemImage: "gearshape")
                }

                NavigationLink(
                    tag: SettingsNavigationItem.accounts,
                    selection: $selectedNavigationItem
                ) {
                    SettingsAccountsView()
                } label: {
                    Label("Accounts", systemImage: "person.3")
                }
            }

            Section {
                let marketingVersionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
                let versionString = (Bundle.main.infoDictionary?["CFBundleVersion"] as? String).flatMap { String("(\($0))") }

                TweetNestStack {
                    Text("App Version")
                    #if !os(watchOS)
                    Spacer()
                    #endif
                    Text(verbatim: [marketingVersionString, versionString].compactMap { $0 }.joined(separator: " "))
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("About")
            }
        }
        .navigationTitle(Text("Settings"))
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
    #endif
}

struct SettingsMainView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsMainView()
    }
}
