//
//  ImageView.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/02/24.
//

import SwiftUI
import Combine

struct ImageView: View {
    let url: URL
    let placeholderImage: Image?

    @State private var image: Image?
    @State private var imageCancellable: AnyCancellable?

    var body: some View {
        ZStack {
            if let image = image {
                image
            } else if let placeholderImage = placeholderImage {
                placeholderImage
            } else {
                EmptyView()
            }
        }
        .onAppear(perform: {
            self.imageCancellable = URLSession.shared
                .dataTaskPublisher(for: url)
                .compactMap {
                    #if os(macOS)
                    return NSImage(data: $0.data).flatMap { Image(nsImage: $0) }
                    #elseif os(iOS)
                    return UIImage(data: $0.data).flatMap { Image(uiImage: $0) }
                    #endif
                }
                .subscribe(on: DispatchQueue.global(qos: .default))
                .receive(on: DispatchQueue.main)
                .sink { debugPrint($0) } receiveValue: {
                    self.image = $0
                }
        })
    }

    init(url: URL, placeholderImage: Image? = nil) {
        self.url = url
        self.placeholderImage = placeholderImage
    }
}

#if DEBUG
struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView(url: URL(string: "https://abs.twimg.com/sticky/default_profile_images/default_profile_normal.png")!, placeholderImage: nil)
    }
}
#endif
