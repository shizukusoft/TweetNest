//
//  PDFView.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/10/02.
//

#if canImport(PDFKit)
import SwiftUI
import class PDFKit.PDFView
import class PDFKit.PDFDocument

struct PDFView {
    let document: PDFDocument

    func makeView() -> PDFKit.PDFView {
        let view = PDFKit.PDFView()
        view.document = document
        view.autoScales = true

        return view
    }
}

#if os(macOS)
extension TweetNest.PDFView: NSViewRepresentable {
    func makeNSView(context: Context) -> PDFKit.PDFView {
        return makeView()
    }

    func updateNSView(_ nsView: PDFKit.PDFView, context: Context) { }
}
#elseif os(iOS)
extension TweetNest.PDFView: UIViewRepresentable {
    func makeUIView(context: Context) -> PDFKit.PDFView {
        return makeView()
    }

    func updateUIView(_ nsView: PDFKit.PDFView, context: Context) { }
}
#endif

struct PDFView_Previews: PreviewProvider {
    static var previews: some View {
        PDFView(document: PDFDocument())
    }
}
#endif
