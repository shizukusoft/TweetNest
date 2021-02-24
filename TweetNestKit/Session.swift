//
//  Session.swift
//  TweetNestKit
//
//  Created by Jaehong Kang on 2021/02/23.
//

import CoreData
import AuthenticationServices
import TwitterKit
import TweetNestAuthSupport

public class Session {
    public static let shared = Session()

    public private(set) lazy var globalQueue = DispatchQueue(label: "\(String(reflecting: Session.self))", qos: .default, attributes: .concurrent)
    public private(set) lazy var mainQueue = DispatchQueue(label: "\(String(reflecting: Session.self)).main", qos: .default, target: globalQueue)

    private var twitterSessions = [Int64: TwitterKit.Session]()
    public let container: NSPersistentCloudKitContainer

    public init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "TweetNestKit", managedObjectModel: NSManagedObjectModel(contentsOf: Bundle(for: Self.self).url(forResource: "TweetNestKit", withExtension: "momd")!)!)
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }

    func twitterSession(for accountID: Int64? = nil) -> TwitterKit.Session {
        if let accountID = accountID, let session = mainQueue.sync(execute: { twitterSessions[accountID] }) {
            return session
        }

        let session = TwitterKit.Session(consumerKey: TweetNestAuthSupport.twitterAPIKey, consumerSecret: TweetNestAuthSupport.twitterAPISecret)

        if let accountID = accountID {
            mainQueue.async {
                self.twitterSessions[accountID] = session
            }
        }

        return session
    }

    func destroyTwitterSession(for accountID: Int64) {
        mainQueue.async {
            self.twitterSessions[accountID] = nil
        }
    }

    public func authorizeNewAccount(
        webAuthenticationSessionHandler: @escaping (ASWebAuthenticationSession) -> Void,
        resultHandler: @escaping (Result<Void, Swift.Error>) -> Void
    ) {
        let twitterSession = self.twitterSession()

        twitterSession.oauth1Authenticator.fetchRequestToken(callback: "tweet-nest://") { requestTokenResult in
            switch requestTokenResult {
            case .success(let requestToken):
                webAuthenticationSessionHandler(
                    ASWebAuthenticationSession(url: URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")!, callbackURLScheme: "tweet-nest", completionHandler: { (url, error) in
                        if let error = error {
                            resultHandler(.failure(error))
                        } else {
                            let urlComponents = URLComponents(url: url!, resolvingAgainstBaseURL: true)

                            let token = urlComponents?.queryItems?.first(where: { $0.name == "oauth_token" })?.value ?? ""
                            let verifier = urlComponents?.queryItems?.first(where: { $0.name == "oauth_verifier" })?.value ?? ""

                            twitterSession.oauth1Authenticator.fetchAccessToken(token: token, verifier: verifier) { result in
                                switch result {
                                case .success(let accessToken):
                                    let credential = OAuth1Credential(tokenResponse: accessToken)
                                    twitterSession.oauth1Credential = credential
                                    User.fetchMe(session: twitterSession) { result in
                                        switch result {
                                        case .success(let user):
                                            self.twitterSessions[user.id] = twitterSession
                                            self.addNewAccount(credential: credential, user: user)
                                            resultHandler(.success(()))
                                        case .failure(let error):
                                            resultHandler(.failure(error))
                                        }
                                    }
                                case .failure(let error):
                                    resultHandler(.failure(error))
                                }
                            }
                        }
                    })
                )
            case .failure(let error):
                resultHandler(.failure(error))
            }
        }
    }

    private func addNewAccount(credential: OAuth1Credential, user: User) {
        
    }
}
