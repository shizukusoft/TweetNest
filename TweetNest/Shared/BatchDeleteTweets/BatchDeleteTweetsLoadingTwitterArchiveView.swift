//
//  BatchDeleteTweetsLoadingTwitterArchiveView.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/09/19.
//

#if canImport(JavaScriptCore)

import SwiftUI
import UniformTypeIdentifiers
import OrderedCollections
import UnifiedLogging
import TweetNestKit
import Twitter

struct BatchDeleteTweetsLoadingTwitterArchiveView: View {
    @Binding var sourceTweets: OrderedDictionary<Tweet.ID, Tweet>?

    @State private var isFileImporterPresented: Bool = false
    @State private var allowedFileImporterContentTypes: [UTType] = []

    @State private var isImporting: Bool = false

    @State private var showError: Bool = false
    @State private var error: TweetNestError?

    var body: some View {
        if isImporting == false {
            Menu {
                Button {
                    allowedFileImporterContentTypes = [.zip]
                    isFileImporterPresented = true
                } label: {
                    Text("Open ZIP File")
                }

                Button {
                    allowedFileImporterContentTypes = [.folder]
                    isFileImporterPresented = true
                } label: {
                    Text("Open Folder")
                }
            } label: {
                Text("Open Twitter Archive")
            } primaryAction: {
                allowedFileImporterContentTypes = [.zip]
                isFileImporterPresented = true
            }
            .fileImporter(isPresented: $isFileImporterPresented, allowedContentTypes: allowedFileImporterContentTypes, onCompletion: onFileImporterCompletion(result:))
        } else {
            ProgressView("Loading Archive...")
                .alert(isPresented: $showError, error: error)
        }
    }

    func onFileImporterCompletion(result: Result<URL, Error>) {
        withAnimation {
            isImporting = true
        }

        Task {
            do {
                let url = try result.get()

                _ = url.startAccessingSecurityScopedResource()
                defer {
                    url.stopAccessingSecurityScopedResource()
                }

                let twitterArchive = TwitterArchive(url: url)

                let tweets: OrderedDictionary<Tweet.ID, [Tweet]> = OrderedDictionary(
                    grouping: try await twitterArchive.tweets
                ) { $0.id }

                withAnimation {
                    self.sourceTweets = tweets.compactMapValues { $0.last }
                }
            } catch {
                Logger().error("Error: \(error as NSError)")
                self.error = TweetNestError(error)
                showError = true
            }
        }
    }
}

struct BatchDeleteTweetsLoadingTwitterArchiveView_Previews: PreviewProvider {
    static var previews: some View {
        BatchDeleteTweetsLoadingTwitterArchiveView(sourceTweets: .constant(nil))
    }
}

#endif
