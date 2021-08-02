//
//  SafariWebExtensionHandler.swift
//  Shared
//
//  Created by Jaehong Kang on 2021/08/02.
//

import SafariServices
import os.log

class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {
    func beginRequest(with context: NSExtensionContext) {
        context.completeRequest(returningItems: [], completionHandler: nil)
    }
}
