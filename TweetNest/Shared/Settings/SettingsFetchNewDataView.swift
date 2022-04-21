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
            Text("Every 5 minutes")
                .tag(TimeInterval(5 * 60))

            Text("Every 10 minutes")
                .tag(TimeInterval(10 * 60))

            Text("Every 15 minutes")
                .tag(TimeInterval(15 * 60))

            Text("Every 30 minutes")
                .tag(TimeInterval(30 * 60))

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

    #if (canImport(BackgroundTasks) && !os(macOS)) || canImport(WatchKit)
    @ViewBuilder var backgroundUpdateToggle: some View {
        Toggle("Background Update", isOn: $backgroundUpdate)
    }
    #endif

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
                    backgroundUpdateToggle
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
