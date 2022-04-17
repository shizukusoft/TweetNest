//
//  SettingsAboutView.swift
//  TweetNest
//
//  Created by 강재홍 on 2022/04/17.
//

import SwiftUI

struct SettingsAboutView: View {
    var body: some View {
        Form {
            Section {
                Group {
                    let marketingVersionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
                    let buildVersionString = (Bundle.main.infoDictionary?["CFBundleVersion"] as? String).flatMap({String("(\($0))")})
                    let versionString = [marketingVersionString, buildVersionString].compactMap({$0}).joined(separator: " ")

                    TweetNestStack {
                        Text("App Version")
                        #if !os(watchOS)
                        Spacer()
                        #endif
                        Text(versionString)
                        .foregroundColor(.secondary)
                    }
                    #if !os(watchOS)
                    .contextMenu {
                        Button(
                            action: {
                                #if canImport(AppKit)
                                NSPasteboard.general.setString(versionString, forType: .string)
                                #elseif canImport(UIKit)
                                UIPasteboard.general.string = versionString
                                #endif
                            },
                            label: {
                                Label("Copy", systemImage: "doc.on.doc")
                            }
                        )
                    }
                    #endif
                }
            }

            Section {
                NavigationLink {
                    SettingsDiagnosticsView()
                } label: {
                    Text("Diagnostics")
                }
            }
        }
        .navigationTitle("About")
    }
}

struct SettingsAboutView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsAboutView()
    }
}
