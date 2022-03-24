//
//  SettingsNotificationsView.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/10/04.
//

import SwiftUI
import TweetNestKit

struct SettingsNotificationsView: View {
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

    @State var showError: Bool = false
    @State var error: TweetNestError?

    var body: some View {
        Form {
            Section {
                Toggle("Notify Profile Changes", isOn: Binding<Bool>(get: { managedPreferences.notifyProfileChanges }, set: { managedPreferences.notifyProfileChanges = $0 }))
                    .onChange(of: managedPreferences.notifyProfileChanges) { _ in
                        save()
                    }

                Toggle("Notify Following Changes", isOn: Binding<Bool>(get: { managedPreferences.notifyFollowingChanges }, set: { managedPreferences.notifyFollowingChanges = $0 }))
                    .onChange(of: managedPreferences.notifyFollowingChanges) { _ in
                        save()
                    }

                Toggle("Notify Follower Changes", isOn: Binding<Bool>(get: { managedPreferences.notifyFollowerChanges }, set: { managedPreferences.notifyFollowerChanges = $0 }))
                    .onChange(of: managedPreferences.notifyFollowerChanges) { _ in
                        save()
                    }

                Toggle("Notify Blocking Changes", isOn: Binding<Bool>(get: { managedPreferences.notifyBlockingChanges }, set: { managedPreferences.notifyBlockingChanges = $0 }))
                    .onChange(of: managedPreferences.notifyBlockingChanges) { _ in
                        save()
                    }

                Toggle("Notify Muting Changes", isOn: Binding<Bool>(get: { managedPreferences.notifyMutingChanges }, set: { managedPreferences.notifyMutingChanges = $0 }))
                    .onChange(of: managedPreferences.notifyMutingChanges) { _ in
                        save()
                    }
            }
        }
        .navigationTitle("Notifications")
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

struct SettingsNotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsNotificationsView()
    }
}
