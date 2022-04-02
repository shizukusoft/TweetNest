//
//  AppStatusView.swift
//  TweetNest
//
//  Created by 강재홍 on 2022/04/02.
//

import SwiftUI
import Combine
import TweetNestKit

struct AppStatusView: View {
    let isPersistentContainerLoaded: Bool

    @State private var disposables = Set<AnyCancellable>()
    @State private var persistentContainerCloudKitEvents: [PersistentContainer.CloudKitEvent] = []

    private var loadingText: Text? {
        let inProgressPersistentContainerCloudKitEvent = persistentContainerCloudKitEvents.first { $0.endDate == nil }

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
        .onAppear {
            TweetNestApp.session.persistentContainer.$cloudKitEvents
                .map { $0.map { $0.value } }
                .receive(on: DispatchQueue.main)
                .assign(to: \.persistentContainerCloudKitEvents, on: self)
                .store(in: &disposables)
        }
    }
}

struct AppStatusView_Previews: PreviewProvider {
    static var previews: some View {
        AppStatusView(isPersistentContainerLoaded: false)
    }
}
