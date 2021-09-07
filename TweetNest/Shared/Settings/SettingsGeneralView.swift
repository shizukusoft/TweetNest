//
//  SettingsGeneralView.swift
//  SettingsGeneralView
//
//  Created by Jaehong Kang on 2021/09/07.
//

import SwiftUI
import TweetNestKit

struct SettingsGeneralView: View {
    @AppStorage(Session.backgroundUpdateUserDefaultsKey)
    var backgroundUpdate: Bool = true
    
    @AppStorage(Session.downloadsDataAssetsUsingExpensiveNetworkAccessUserDefaultsKey)
    var downloadsImagesUsingExpensiveNetworkAccess: Bool = true
    
    var body: some View {
        Form {
            Section {
                Toggle(String(localized: "Background Update"), isOn: $backgroundUpdate)
            } footer: {
                Text("Update accounts in background on this device.")
                    #if os(macOS)
                    .foregroundColor(.secondary)
                    .font(.footnote)
                    #endif
            }
            
            #if os(iOS) || os(watchOS)
            Section {
                Toggle(String(localized: "Download Images Using Cellular"), isOn: $downloadsImagesUsingExpensiveNetworkAccess)
            } footer: {
                Text("Downloads images using cellular or personal hotspot on this deivce when other networks are not available. If \"Allow More Data on 5G\" is turned on this device, this option will be ignored.")
            }
            #endif
            
            #if os(iOS)
            Section {
                Link(destination: URL(string: UIApplication.openSettingsURLString)!) {
                    Text("Additional Settings")
                }
            }
            #endif
        }
        .navigationTitle("General")
    }
}

struct SettingsGeneralView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsGeneralView()
    }
}
