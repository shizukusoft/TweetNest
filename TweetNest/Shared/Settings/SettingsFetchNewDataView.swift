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

    static var fetchNewDataIntervalOptions: Set<TimeInterval> {
        [
            5 * 60,
            10 * 60,
            15 * 60,
            30 * 60,
            60 * 60
        ]
    }

    @AppStorage(TweetNestKitUserDefaults.DefaultsKeys.isBackgroundUpdateEnabled)
    var backgroundUpdate: Bool = true

    @ViewBuilder var fetchNewDataIntervalPicker: some View {
        Picker(selection: $fetchNewDataInterval) {
            ForEach(Self.fetchNewDataIntervalOptions.sorted(), id: \.self) { timeInterval in
                let datesRange = Date(timeIntervalSinceReferenceDate: 0)..<Date(timeIntervalSinceReferenceDate: timeInterval)

                Text("Every \(datesRange, format: .components(style: .narrow))")
            }

            #if os(macOS)
            Divider()
            #endif

            Text("Manually")
                .tag(TimeInterval(0))
        } label: {
            #if os(macOS)
            Text("Fetch new data")
            #endif
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

#if DEBUG
struct SettingsFetchNewDataView_Previews: PreviewProvider {

    static var previews: some View {
        NavigationView {
            List {
                SettingsFetchNewDataView()
            }
            #if os(iOS) || os(watchOS)
            .navigationBarHidden(true)
            #endif
        }
    }
}
#endif
