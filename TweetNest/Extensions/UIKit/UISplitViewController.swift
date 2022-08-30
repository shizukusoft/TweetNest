//
//  UISplitViewController.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2022/08/28.
//

#if os(iOS)

import UIKit

extension UISplitViewController {
    @available(iOS, deprecated: 16.0)
    open override func viewDidLoad() {
        if #unavailable(iOS 16.0) {
            preferredDisplayMode = .twoDisplaceSecondary
        }

        super.viewDidLoad()
    }
}

#endif
