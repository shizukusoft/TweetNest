//
//  SettingsGeneralView.swift
//  SettingsGeneralView
//
//  Created by Jaehong Kang on 2021/09/07.
//

import SwiftUI
import TweetNestKit

struct SettingsGeneralView: View {
    
    @AppStorage(Session.downloadUserProfileImagesUserDefaultsKey)
    var downloadUserProfileImages: Bool = true
    
    var body: some View {
        Form {
            Section {
                Toggle(String(localized: "Download User Profile Images"), isOn: $downloadUserProfileImages)
                
                #if os(iOS)
                Link(destination: URL(string: UIApplication.openSettingsURLString)!) {
                    Text("Additional Settings")
                }
                #endif
            } header: {
                Text("Device Settings")
                    #if os(macOS)
                    .foregroundColor(.secondary)
                    #endif
            }
        }
        .navigationTitle("General")
    }
}

struct SettingsGeneralView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsGeneralView()
    }
}
