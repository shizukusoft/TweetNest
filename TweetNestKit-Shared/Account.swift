//
//  Account.swift
//  TweetNestKit
//
//  Created by Jaehong Kang on 2021/02/24.
//

import Foundation
import TwitterKit

extension Account {
    func updateUser(session: Session = .shared, completion: ((Result<Bool, Swift.Error>) -> Void)? = nil) {
        session.fetchTwitterSession(for: self.user?.id) { sessionResult in
            switch sessionResult {
            case .success(let twitterSession):
                TwitterKit.Account.fetchMe(session: twitterSession) { result in
                    switch result {
                    case .success(let account):
                        TwitterKit.User.fetchUser(id: account.id, session: twitterSession) { result in
                            switch result {
                            case .success(let twitterUser):
                                session.container.performBackgroundTask { context in
                                    do {
                                        try User.update(twitterUser, context: context)

                                        let hasChanges = context.hasChanges

                                        if hasChanges {
                                            try context.save()
                                        }

                                        completion?(.success(hasChanges))
                                    } catch {
                                        completion?(.failure(error))
                                    }
                                }
                            case .failure(let error):
                                completion?(.failure(error))
                            }
                        }
                    case .failure(let error):
                        completion?(.failure(error))
                    }
                }
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }
}
