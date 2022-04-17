//
//  SettingsDiagnosticsView.swift
//  TweetNest
//
//  Created by 강재홍 on 2022/04/17.
//

import SwiftUI
import CoreData
import TweetNestKit

struct SettingsDiagnosticsView: View {
    @State private var cloudKitEvents = TweetNestApp.session.persistentContainer.cloudKitEvents

    var body: some View {
        Form {
            Section {
                ForEach(cloudKitEvents.values, id: \.identifier) { cloudKitEvent in
                    HStack {
                        let storeConfigurationName = TweetNestApp.session.persistentContainer.persistentStoreCoordinator.persistentStores.first(where: { $0.identifier == cloudKitEvent.storeIdentifier })?.configurationName ?? cloudKitEvent.storeIdentifier

                        switch storeConfigurationName {
                        case "Accounts":
                            Text("Accounts")
                        case "DataAssets":
                            Text("Resources")
                        case "TweetNestKit":
                            Text("User Infos")
                        default:
                            Text(storeConfigurationName)
                        }

                        switch cloudKitEvent.result {
                        case .none:
                            ProgressView()
                        case .some(.success(_)):
                            Text("Succeed")
                        case .some(.failure(_)):
                            Text("Failed")
                        }
                    }
                }
            } header: {
                Text("iCloud")
            }
        }
        .onChange(of: TweetNestApp.session.persistentContainer.cloudKitEvents) { newValue in
            self.cloudKitEvents = newValue
        }
    }
}

struct SettingsDiagnosticsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsDiagnosticsView()
    }
}
