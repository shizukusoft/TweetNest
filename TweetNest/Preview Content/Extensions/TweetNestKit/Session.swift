//
//  TweetNestKit.Session.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/02/23.
//

import TweetNestKit

extension TweetNestKit.Session {
    public static let preview: Session = {
        let session = Session(inMemory: true)
        session.persistentContainer.injectPreviewData()
        return session
    }()
}
