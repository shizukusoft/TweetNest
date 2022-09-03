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

@MainActor
struct AppStatusView: View {
    let isPersistentContainerLoaded: Bool

    @State private var inProgressPersistentContainerCloudKitEvent = TweetNestApp.session.persistentContainer.cloudKitEvents.values.last { $0.endDate == nil }

    private var loadingText: LocalizedStringKey? {
        switch (isPersistentContainerLoaded, inProgressPersistentContainerCloudKitEvent?.type) {
        case (false, _):
            return "Loading…"
        case (_, .setup?):
            return "Preparing to Sync…"
        case (_, .import?), (_, .export?), (_, .unknown?):
            return "Syncing…"
        case (true, nil):
            return nil
        }
    }

    @ViewBuilder
    private var statusView: some View {
        if let loadingText = loadingText {
            HStack(spacing: 4) {
                #if os(iOS)
                ProgressView()
                    .progressViewStyle(.circular)
                    .accessibilityHidden(true)
                #endif

                Text(loadingText)
                    #if !os(watchOS)
                    .font(.system(.callout))
                    .foregroundColor(.secondary)
                    #endif
            }
            #if !os(watchOS)
            .padding(8)
            #endif
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.updatesFrequently)
        }
    }

    var body: some View {
        statusView
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
