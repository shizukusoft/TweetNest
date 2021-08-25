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
    
    @State var editMode: EditMode = .inactive
    
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
        #elseif os(iOS)
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            EditButton()
        }
        .environment(\.editMode, $editMode)
        #endif
    }
}

struct SettingsMainView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsMainView()
    }
}
