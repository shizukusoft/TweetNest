//
//  BatchDeleteTweetsProgressView.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/09/19.
//

import SwiftUI
import OrderedCollections
import Algorithms
import BackgroundTask
import UnifiedLogging
import TweetNestKit
import Twitter

struct BatchDeleteTweetsProgressView: View {
    @Environment(\.account) private var account: ManagedAccount?

    let targetTweets: OrderedDictionary<Tweet.ID, Tweet>
    @Binding var isBatchDeletionExecuting: Bool
    @Binding var isBatchDeletionFinished: Bool

    @MainActor @State private var progress: Progress
    @State private var results: [Int: Result<Void, Error>] = [:]

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
                .padding()

        }
        .onAppear {
            withAnimation {
                updateProgress()
            }
        }
        .task {
            await delete()
        }
    }

    init(
        targetTweets: OrderedDictionary<Tweet.ID, Tweet>,
        isBatchDeletionExecuting: Binding<Bool>,
        isBatchDeletionFinished: Binding<Bool>
    ) {
        self.targetTweets = targetTweets
        self._isBatchDeletionExecuting = isBatchDeletionExecuting
        self._isBatchDeletionFinished = isBatchDeletionFinished

        _progress = State(initialValue: Progress(totalUnitCount: Int64(targetTweets.count)))
    }

    private func delete() async {
        guard isBatchDeletionExecuting == false else { return }

        isBatchDeletionExecuting = true
        defer {
            isBatchDeletionExecuting = false
        }

        guard let account = account else {
            return
        }

        defer {
            if Task.isCancelled {
                DispatchQueue.main.async {
                    progress.cancel()
                }
            }
        }

        do {
            try await withExtendedBackgroundExecution {
                await withTaskGroup(of: (Int, Result<Void, Error>).self) { taskGroup in
                    for (index, targetTweetID) in targetTweets.keys.indexed() {
                        taskGroup.addTask {
                            do {
                                try await Tweet.delete(targetTweetID, session: .session(for: account, session: TweetNestApp.session))
                                return (index, .success(()))
                            } catch {
                                return (index, .failure(error))
                            }
                        }
                    }

                    for await result in taskGroup {
                        results[result.0] = result.1
                        await updateProgress()
                    }

                    isBatchDeletionFinished = true
                }
            }
        } catch {
            Logger().error("Error occurred: \(String(reflecting: error), privacy: .public)")
        }
    }

    @MainActor
    private func updateProgress() {
        withAnimation {
            progress.completedUnitCount = Int64(results.count)
            progress.localizedDescription = String(localized: "Deleting \(progress.totalUnitCount.twnk_formatted()) tweets…")
            progress.localizedAdditionalDescription = {
                var localizedAdditionalDescription = String(
                    localized: "\(progress.completedUnitCount.twnk_formatted()) of \(progress.totalUnitCount.twnk_formatted()) tweets deletion requested."
                )

                let failedResultsCount = failedResults.count

                if failedResultsCount > 0 {
                    localizedAdditionalDescription.append("\n")
                    localizedAdditionalDescription.append(String(localized: "\(failedResultsCount.twnk_formatted()) tweets failed to delete."))
                }

                return localizedAdditionalDescription
            }()
        }
    }
}

#if DEBUG
struct BatchDeleteTweetsProgressView_Previews: PreviewProvider {

    static var previews: some View {
        ZStack {
            List {
                EmptyView()
            }
            BatchDeleteTweetsProgressView(
                targetTweets: [:],
                isBatchDeletionExecuting: .constant(false),
                isBatchDeletionFinished: .constant(false))
        }
    }
}
#endif
