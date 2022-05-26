//
//  Session+Preview.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/02/23.
//

#if DEBUG
import TweetNestKit

extension TweetNestKit.Session {

    static let preview: Session = {
        let session = Session(inMemory: true)
        session.persistentContainer.injectPreviewData()
        return session
    }()
}
#endif
