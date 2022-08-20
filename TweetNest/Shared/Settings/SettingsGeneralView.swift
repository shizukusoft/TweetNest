//
//  SettingsGeneralView.swift
//  SettingsGeneralView
//
//  Created by Jaehong Kang on 2021/09/07.
//

import SwiftUI
import TweetNestKit

struct SettingsGeneralView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        fetchRequest: {
            let fetchReuqest = ManagedPreferences.fetchRequest()
            fetchReuqest.sortDescriptors = [NSSortDescriptor(keyPath: \ManagedPreferences.modificationDate, ascending: false)]
            fetchReuqest.fetchLimit = 1

            return fetchReuqest
        }(),
        animation: .default
    )
    private var _managedPreferences: FetchedResults<ManagedPreferences>

    private var managedPreferences: ManagedPreferences {
        _managedPreferences.first ?? ManagedPreferences(context: viewContext)
    }

    @AppStorage(TweetNestKitUserDefaults.DefaultsKeys.downloadsDataAssetsUsingExpensiveNetworkAccess)
    var downloadsImagesUsingExpensiveNetworkAccess: Bool = true

    @State var showError: Bool = false
    @State var error: TweetNestError?

    var body: some View {
        Form {
            Section {
                SettingsFetchNewDataView()
            }

            #if os(iOS) || os(watchOS)
            Section {
                Toggle("Download Images Using Cellular", isOn: $downloadsImagesUsingExpensiveNetworkAccess)
            } footer: {
                // swiftlint:disable:next line_length
                Text("Downloads images using cellular or personal hotspot on this deivce when other networks are not available. If “Allow More Data on 5G” is turned on this device, this option will be ignored.")
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
        .alert(isPresented: $showError, error: error)
    }

    func save() {
        do {
            try viewContext.save()
        } catch {
            self.error = TweetNestError(error)
            showError = true
        }
    }
}

struct SettingsGeneralView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsGeneralView()
    }
}
