//
//  SettingsFetchNewDataView.swift
//  TweetNest
//
//  Created by 강재홍 on 2022/04/20.
//

import SwiftUI
import TweetNestKit

struct SettingsFetchNewDataView: View {
    @AppStorage(TweetNestKitUserDefaults.DefaultsKeys.fetchNewDataInterval)
    var fetchNewDataInterval: TimeInterval = TweetNestKitUserDefaults.standard.fetchNewDataInterval

    @AppStorage(TweetNestKitUserDefaults.DefaultsKeys.isBackgroundUpdateEnabled)
    var backgroundUpdate: Bool = true

    @ViewBuilder var fetchNewDataIntervalPicker: some View {
        Picker(selection: $fetchNewDataInterval) {
            ForEach([5, 10, 15, 30], id: \.self) { minutes in
                Text("Every \(minutes) minutes")
                    .tag(TimeInterval(minutes * 60))
            }

            Text("Every hour")
                .tag(TimeInterval(60 * 60))

            #if os(macOS)
            Divider()
            #endif

            Text("Manually")
                .tag(TimeInterval(0))
        } label: {

        }
    }

    var body: some View {
        #if os(macOS)
        fetchNewDataIntervalPicker
        #else
        NavigationLink {
            Form {
                Section {
                    fetchNewDataIntervalPicker
                        .pickerStyle(.inline)
                }

                #if (canImport(BackgroundTasks) && !os(macOS)) || canImport(WatchKit)
                Section {
                    Toggle("Background Update", isOn: $backgroundUpdate)
                } footer: {
                    Text("Update accounts in background on this device.")
                }
                #endif
            }
            .navigationTitle("Fetch New Data")
        } label: {
            Text("Fetch New Data")
        }
        #endif
    }
}

struct SettingsFetchNewDataView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsFetchNewDataView()
    }
}
