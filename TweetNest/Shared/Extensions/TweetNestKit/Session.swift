//
//  TweetNestKit.Session.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/02/23.
//

import Foundation
import UnifiedLogging
import TweetNestKit

extension TweetNestKit.Session {
    public static var preview: Session = {
        let session = Session(inMemory: true)

        Task.detached {
            do {
                try await session.persistentContainer.loadPersistentStores()

                DispatchQueue.main.async {
                    let viewContext = session.persistentContainer.viewContext

                    let tweetnestAccount = Account(context: viewContext)
                    tweetnestAccount.creationDate = Date(timeIntervalSince1970: 1628780400)
                    tweetnestAccount.userID = "1352231658661920770"

                    let tweetnestUser = User(context: viewContext)
                    tweetnestUser.creationDate = Date(timeIntervalSince1970: 1628780400)
                    tweetnestUser.lastUpdateStartDate = Date(timeIntervalSince1970: 1628780400)
                    tweetnestUser.lastUpdateEndDate = Date(timeIntervalSince1970: 1628780400)
                    tweetnestUser.modificationDate = Date(timeIntervalSince1970: 1628780400)
                    tweetnestUser.id = "1352231658661920770"

                    let tweetnestUserDetail1 = UserDetail(context: viewContext)
                    tweetnestUserDetail1.creationDate = Date(timeIntervalSince1970: 1628780400)
                    tweetnestUserDetail1.followerUserIDs = []
                    tweetnestUserDetail1.followerUsersCount = 0
                    tweetnestUserDetail1.followingUserIDs = []
                    tweetnestUserDetail1.followingUsersCount = 0
                    tweetnestUserDetail1.userCreationDate = Date(timeIntervalSinceReferenceDate: 638050017)
                    tweetnestUserDetail1.location = "대한민국 서울"
                    tweetnestUserDetail1.name = "TweetNest"
                    tweetnestUserDetail1.username = "TweetNest_App"
                    tweetnestUserDetail1.profileImageURL = URL(string: "https://pbs.twimg.com/profile_images/1373878674903113729/JL3SGoch.png")
                    tweetnestUserDetail1.url = URL(string: "https://www.tweetnest.com")
                    tweetnestUserDetail1.user = tweetnestUser

                    let tweetnestProfileImageDataAsset = DataAsset(context: viewContext)
                    tweetnestProfileImageDataAsset.url = tweetnestUserDetail1.profileImageURL
                    tweetnestProfileImageDataAsset.data = tweetnestUserDetail1.profileImageURL.flatMap { try? Data(contentsOf: $0) }

                    do {
                        try viewContext.save()
                    } catch {
                        // Replace this implementation with code to handle the error appropriately.
                        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }
                }
            } catch {
                Logger().error("Error occurred while load persistent stores: \(error as NSError, privacy: .public)")
            }
        }

        return session
    }()
    
}

extension TweetNestKit.Account {
    public static var preview: Account {
        let fetchRequest = Account.fetchRequest()

        return try! Session.preview.persistentContainer.viewContext.fetch(fetchRequest)[0]
    }
}
