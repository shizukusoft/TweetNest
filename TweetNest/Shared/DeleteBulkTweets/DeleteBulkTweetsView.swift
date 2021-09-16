//
//  DeleteBulkTweetsView.swift
//  DeleteBulkTweetsView
//
//  Created by Jaehong Kang on 2021/08/19.
//

import SwiftUI
import TweetNestKit
import Twitter
import OrderedCollections
import UnifiedLogging

struct DeleteBulkTweetsView: View {
    @Environment(\.account) private var account: TweetNestKit.Account?

    @Binding var isPresented: Bool
    let targetTweetIDs: OrderedSet<Tweet.ID>

    @State var progress: Progress
    @State var results: [Int: Result<Void, Error>] = [:]

    var succeedResultsCount: Int {
        results
            .lazy
            .map(\.value)
            .filter {
                switch $0 {
                case .success:
                    return true
                case .failure:
                    return false
                }
            }
            .count
    }

    var failedResults: [Error] {
        results
            .sorted { $0.key < $1.key }
            .lazy
            .map(\.value)
            .compactMap {
                switch $0 {
                case .success:
                    return nil
                case .failure(let error):
                    return error
                }
            }
    }

    var body: some View {
        Group {
            ProgressView(progress)
                .progressViewStyle(.linear)
                .padding(16)
                .interactiveDismissDisabled(progress.isFinished == false)
                .toolbar {
                    ToolbarItemGroup(placement: .cancellationAction) {
                        if progress.isFinished == false {
                            Button(role: .cancel) {
                                isPresented = false
                            } label: {
                                Text("Cancel")
                            }
                        }
                    }

                    ToolbarItemGroup(placement: .confirmationAction) {
                        if progress.isFinished {
                            Button {
                                isPresented = false
                            } label: {
                                Text("Done")
                            }
                        }
                    }
                }
        }
        .task {
            await delete()
        }
    }

    init(isPresented: Binding<Bool>, targetTweetIDs: OrderedSet<Tweet.ID>) {
        _isPresented = isPresented
        self.targetTweetIDs = targetTweetIDs

        _progress = State(initialValue: Progress(totalUnitCount: Int64(targetTweetIDs.count)))
        updateProgressDescription()
    }

    private func delete() async {
        await withExtendedBackgroundExecution {
            await withTaskCancellationHandler {
                guard let account = account else {
                    return
                }

                await withTaskGroup(of: (Int, Result<Void, Error>).self) { taskGroup in
                    for (offset, targetTweetID) in targetTweetIDs.enumerated() {
                        taskGroup.addTask {
                            do {
                                try await Tweet.delete(targetTweetID, session: .session(for: account))
                                return (offset, .success(()))
                            } catch {
                                return (offset, .failure(error))
                            }
                        }
                    }

                    for await result in taskGroup {
                        results[result.0] = result.1

                        progress.completedUnitCount = Int64(results.count)
                        updateProgressDescription()
                    }
                }
            } onCancel: {
                progress.cancel()
            }
        }
    }

    private func updateProgressDescription() {
        progress.localizedDescription = String(localized: "Deleting \(progress.totalUnitCount.twnk_formatted()) tweets...")
        progress.localizedAdditionalDescription = {
            var localizedAdditionalDescription = String(localized: "\(progress.completedUnitCount.twnk_formatted()) of \(progress.totalUnitCount.twnk_formatted()) tweets.")

            let failedResultsCount = failedResults.count

            if failedResultsCount > 0 {
                localizedAdditionalDescription.append("\n")
                localizedAdditionalDescription.append(String(localized: "\(failedResultsCount.twnk_formatted()) tweets failed."))
            }

            return localizedAdditionalDescription
        }()
    }
}

struct DeleteBulkTweetsView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteBulkTweetsView(isPresented: .constant(true), targetTweetIDs: [])
    }
}
