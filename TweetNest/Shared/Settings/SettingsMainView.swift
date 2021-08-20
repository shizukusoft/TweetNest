//
//  SettingsMainView.swift
//  SettingsMainView
//
//  Created by Jaehong Kang on 2021/08/16.
//

import SwiftUI

struct SettingsMainView: View {
    private enum Tabs: Hashable {
        case accounts
    }
    
    var body: some View {
        #if os(macOS)
        TabView {
            List {
                SettingsAccountItems()
            }
            .tabItem {
                Label("Accounts", systemImage: "person.3")
            }
            .tag(Tabs.accounts)
        }
        #else
        Form {
            Section {
                SettingsAccountItems()
            } header: {
                Text("Accounts")
            }
            
            Section {
                let marketingVersionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
                let versionString = (Bundle.main.infoDictionary?["CFBundleVersion"] as? String).flatMap { String("(\($0))") }
                
                HStack {
                    Text("App Version")
                    Spacer()
                    Text(verbatim: [marketingVersionString, versionString].compactMap { $0 }.joined(separator: " "))
                }
            } header: {
                Text("About")
            }
            
            Section {
                Link(destination: URL(string: UIApplication.openSettingsURLString)!) {
                    Text("Additional Settings")
                }
            }
        }
        #if os(iOS)
        .toolbar {
            EditButton()
        }
        #endif
        #endif
    }
}

struct SettingsMainView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsMainView()
    }
}