//
//  DetailImageView.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/10/02.
//

#if canImport(PDFKit)
import SwiftUI
import class PDFKit.PDFDocument
import class PDFKit.PDFPage

struct DetailImageView: View {
    let imageData: Data

    let image: CGImage
    let imageScale: CGFloat

    let filename: String

    @Environment(\.dismiss)
    private var dismiss

    @State private var temporaryFileDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory())
        .appendingPathComponent(UUID().uuidString, isDirectory: true)

    @State private var isFileMoverPresented: Bool = false
    private var temporaryFileURL: URL {
        temporaryFileDirectoryURL.appendingPathComponent(filename)
    }

    @State var showError: Bool = false
    @State var error: TweetNestError?

    private var pdfDocument: PDFDocument {
        let pdfDocument = PDFDocument()
        #if os(macOS)
        let pdfPage = PDFPage(image: NSImage(cgImage: image, size: .zero))
        #elseif os(iOS)
        let pdfPage = PDFPage(image: UIImage(cgImage: image, scale: imageScale, orientation: .up))
        #endif

        if let pdfPage = pdfPage {
            pdfDocument.insert(pdfPage, at: 0)
        }

        return pdfDocument
    }

    @ViewBuilder
    var toolbarItems: some View {
        Button {
            do {
                try? FileManager.default.removeItem(at: temporaryFileURL)

                try imageData.write(to: temporaryFileURL)

                self.isFileMoverPresented = true
            } catch {
                self.error = TweetNestError(error)
                showError = true
            }
        } label: {
            Label("Save", systemImage: "square.and.arrow.down")
        }
    }

    var body: some View {
        PDFView(document: pdfDocument)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .navigationTitle(filename)
            .interactiveDismissDisabled(true)
            .toolbar {
                ToolbarItemGroup(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }

                #if os(iOS)
                ToolbarItemGroup(placement: .bottomBar) {
                    toolbarItems
                }
                #else
                ToolbarItemGroup(placement: .automatic) {
                    toolbarItems
                }
                #endif
            }
            .fileMover(isPresented: $isFileMoverPresented, file: temporaryFileURL) { result in
                do {
                    _ = try result.get()
                } catch {
                    self.error = TweetNestError(error)
                    showError = true
                }
            }
            .onAppear {
                try? FileManager.default.createDirectory(at: temporaryFileDirectoryURL, withIntermediateDirectories: true, attributes: nil)
            }
            .onDisappear {
                try? FileManager.default.removeItem(at: temporaryFileDirectoryURL)
            }
            .alert(isPresented: $showError, error: error)
    }
}

#if DEBUG
struct DetailImageView_Previews: PreviewProvider {

    private static let url: URL =
        .init(string: "https://pbs.twimg.com/profile_images/1373878674903113729/JL3SGoch.png")!

    static var previews: some View {
        let data = NSDataAsset(name: "TweetNestProfileImageData")!.data
        let imageSource = CGImageSourceCreateWithData(data as CFData, nil)!
        let index = CGImageSourceGetPrimaryImageIndex(imageSource)
        let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, index, nil)! as NSDictionary
        let image = CGImageSourceCreateImageAtIndex(imageSource, index, nil)!
        let dpiWidth = (properties[kCGImagePropertyDPIWidth] as? NSNumber)?.doubleValue
        let dpiHeight = (properties[kCGImagePropertyDPIHeight] as? NSNumber)?.doubleValue
        let scale = CGFloat((dpiWidth ?? dpiHeight ?? 72) / 72)
        DetailImageView(
            imageData: data,
            image: image,
            imageScale: scale,
            filename: url.lastPathComponent)
    }
}
#endif

#endif
