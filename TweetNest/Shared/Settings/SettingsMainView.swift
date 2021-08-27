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
    
    #if os(iOS)
    @State var editMode: EditMode = .inactive
    #endif
    
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
            
            #if os(iOS)
            Section {
                Link(destination: URL(string: UIApplication.openSettingsURLString)!) {
                    Text("Additional Settings")
                }
            }
            #endif
        }
        .navigationTitle(Text("Settings"))
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            EditButton()
        }
        .environment(\.editMode, $editMode)
        #endif
        #endif
    }
}

struct SettingsMainView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsMainView()
    }
}
