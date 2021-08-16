//
//  SettingsMainView.swift
//  SettingsMainView
//
//  Created by Jaehong Kang on 2021/08/16.
//

import SwiftUI

struct SettingsMainView: View {
    var body: some View {
        Form {
            SettingsAccountsSection()
        }
        .toolbar {
            #if os(iOS)
            EditButton()
            #endif
        }
    }
}

struct SettingsMainView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsMainView()
    }
}
