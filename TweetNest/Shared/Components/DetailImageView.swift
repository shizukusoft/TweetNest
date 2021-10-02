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
    let image: CGImage

    private var pdfDocument: PDFDocument {
        let pdfDocument = PDFDocument()
        #if os(macOS)
        let pdfPage = PDFPage(image: NSImage(cgImage: image))
        #elseif os(iOS)
        let pdfPage = PDFPage(image: UIImage(cgImage: image))
        #endif

        if let pdfPage = pdfPage {
            pdfDocument.insert(pdfPage, at: 0)
        }

        return pdfDocument
    }

    var body: some View {
        PDFView(document: pdfDocument)
    }
}

//struct DetailImageView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailImageView()
//    }
//}
#endif
