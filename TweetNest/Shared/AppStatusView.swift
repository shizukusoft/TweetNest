//
//  AppStatusView.swift
//  TweetNest
//
//  Created by 강재홍 on 2022/04/02.
//

import SwiftUI
import Combine
import OrderedCollections
import TweetNestKit

struct AppStatusView: View {
    let isPersistentContainerLoaded: Bool

    @State private var inProgressPersistentContainerCloudKitEvent = TweetNestApp.session.persistentContainer.cloudKitEvents.values.last { $0.endDate == nil }

    private var loadingText: Text? {
        switch (isPersistentContainerLoaded, inProgressPersistentContainerCloudKitEvent?.type) {
        case (false, _):
            return Text("Loading…")
        case (_, .setup?):
            return Text("Preparing to Sync…")
        case (_, .import?), (_, .export?), (_, .unknown?):
            return Text("Syncing…")
        case (true, nil):
            return nil
        }
    }

    var body: some View {
        Group {
            if let loadingText = loadingText {
                HStack(spacing: 4) {
                    #if !os(watchOS)
                    ProgressView()
                        .accessibilityHidden(true)
                    #endif

                    loadingText
                        #if !os(watchOS)
                        .font(.system(.callout))
                        .foregroundColor(.secondary)
                        #endif
                        #if os(iOS)
                        .fixedSize()
                        #endif
                }
                .accessibilityElement(children: .combine)
                .accessibilityAddTraits(.updatesFrequently)
            }
        }
        .onReceive(
            TweetNestApp.session.persistentContainer.$cloudKitEvents
        ) {
            self.inProgressPersistentContainerCloudKitEvent = $0.values.last { $0.endDate == nil }
        }
    }
}

struct AppStatusView_Previews: PreviewProvider {
    static var previews: some View {
        AppStatusView(isPersistentContainerLoaded: false)
    }
}
