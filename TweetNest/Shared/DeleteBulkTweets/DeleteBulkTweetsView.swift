//
//  DeleteBulkTweetsView.swift
//  DeleteBulkTweetsView
//
//  Created by Jaehong Kang on 2021/08/19.
//

import SwiftUI
import TweetNestKit
import Twitter
import UnifiedLogging

struct DeleteBulkTweetsView: View {
    @Environment(\.account) private var account: TweetNestKit.Account?
    
    @Binding var isPresented: Bool
    let targetTweets: [Tweet]
    
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
    
    @State var showResults: Bool = false
    
    var body: some View {
        Group {
            ProgressView(progress)
                .progressViewStyle(.linear)
                .padding(16)
                .interactiveDismissDisabled(progress.isFinished == false)
                .toolbar {
                    ToolbarItemGroup(placement: .cancellationAction) {
                        Button(role: .cancel) {
                            isPresented = false
                        } label: {
                            Text("Cancel")
                        }
                    }
                }
        }
        .task {
            await delete()
        }
        .alert(Text("Results"), isPresented: $showResults) {
            Button {
                isPresented = false
            } label: {
                Text("OK")
            }
        } message: {
            Text("Deleting \(succeedResultsCount.formatted()) of \(targetTweets.count.formatted()) tweets succeed. \(failedResults.count.formatted()) tweets failed.")
        }
    }
    
    init(isPresented: Binding<Bool>, targetTweets: [Tweet]) {
        _isPresented = isPresented
        self.targetTweets = targetTweets
        
        _progress = State(initialValue: Progress(totalUnitCount: Int64(targetTweets.count)))
        updateProgressDescription()
    }
    
    private func delete() async {
        guard let account = account else {
            return
        }
        
        let task = Task.detached {
            await withTaskGroup(of: (Int,  Result<Void, Error>).self) { taskGroup in
                for (offset, tweet) in targetTweets.enumerated() {
                    taskGroup.addTask {
                        do {
                            try await tweet.delete(session: .session(for: account))
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
        }
        
        #if os(iOS)
        let backgroundTaskIdentifier = await UIApplication.shared.beginBackgroundTask {
            task.cancel()
            progress.cancel()
        }
        #endif
        
        _ = await task.value
 
        #if os(iOS)
        await UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
        #endif
    }
    
    private func updateProgressDescription() {
        progress.localizedDescription = String(localized: "Deleting \(progress.totalUnitCount.formatted()) tweets...")
        progress.localizedAdditionalDescription = {
            var localizedAdditionalDescription = String(localized: "\(progress.completedUnitCount.formatted()) of \(progress.totalUnitCount.formatted()) tweets.")
            
            let failedResultsCount = failedResults.count
            
            if failedResultsCount > 0 {
                localizedAdditionalDescription.append("\n")
                localizedAdditionalDescription.append(String(localized: "\(failedResultsCount.formatted()) tweets failed."))
            }
            
            return localizedAdditionalDescription
        }()
    }
}

struct DeleteBulkTweetsView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteBulkTweetsView(isPresented: .constant(true), targetTweets: [])
    }
}
