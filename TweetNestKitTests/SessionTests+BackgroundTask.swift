//
//  Session+BackgroundTask.swift
//  Session+BackgroundTask
//
//  Created by Jaehong Kang on 2021/08/30.
//

import XCTest
@testable import TweetNestKit

extension SessionTests {
    func testFollowingUserChanges() {
        withExtendedLifetime(Session(inMemory: true)) { session in
            let oldUserDetail = UserDetail(context: session.persistentContainer.viewContext)
            let newUserDetail = UserDetail(context: session.persistentContainer.viewContext)
            
            oldUserDetail.followingUserIDs = [1, 2, 3, 4, 5].map { String($0) }
            oldUserDetail.followingUsersCount = 6
            newUserDetail.followingUserIDs = [2, 3, 6].map { String($0) }
            newUserDetail.followingUsersCount = 3
            
            XCTAssertEqual(Session.followingUserChanges(oldUserDetail: oldUserDetail, newUserDetail: newUserDetail).followingUsersCount, 1)
            XCTAssertEqual(Session.followingUserChanges(oldUserDetail: oldUserDetail, newUserDetail: newUserDetail).unfollowingUsersCount, 3)
        }
    }
    func testFollowingUserChangesUsingUserIDs() {
        withExtendedLifetime(Session(inMemory: true)) { session in
            let oldUserDetail = UserDetail(context: session.persistentContainer.viewContext)
            let newUserDetail = UserDetail(context: session.persistentContainer.viewContext)
            
            oldUserDetail.followingUserIDs = [1, 2, 3, 4, 5].map { String($0) }
            newUserDetail.followingUserIDs = [2, 3, 6].map { String($0) }
            
            XCTAssertEqual(Session.followingUserChanges(oldUserDetail: oldUserDetail, newUserDetail: newUserDetail).followingUsersCount, 1)
            XCTAssertEqual(Session.followingUserChanges(oldUserDetail: oldUserDetail, newUserDetail: newUserDetail).unfollowingUsersCount, 3)
        }
    }
    
    func testFollowingUserChangesUsingCount() {
        withExtendedLifetime(Session(inMemory: true)) { session in
            let oldUserDetail = UserDetail(context: session.persistentContainer.viewContext)
            let newUserDetail = UserDetail(context: session.persistentContainer.viewContext)
            
            oldUserDetail.followingUsersCount = 3
            newUserDetail.followingUsersCount = 5
            XCTAssertEqual(Session.followingUserChanges(oldUserDetail: oldUserDetail, newUserDetail: newUserDetail).followingUsersCount, 2)
            XCTAssertEqual(Session.followingUserChanges(oldUserDetail: oldUserDetail, newUserDetail: newUserDetail).unfollowingUsersCount, 0)
            
            oldUserDetail.followingUsersCount = 10
            newUserDetail.followingUsersCount = 7
            XCTAssertEqual(Session.followingUserChanges(oldUserDetail: oldUserDetail, newUserDetail: newUserDetail).followingUsersCount, 0)
            XCTAssertEqual(Session.followingUserChanges(oldUserDetail: oldUserDetail, newUserDetail: newUserDetail).unfollowingUsersCount, 3)
        }
    }
    
    func testFollowerUserChanges() {
        withExtendedLifetime(Session(inMemory: true)) { session in
            let oldUserDetail = UserDetail(context: session.persistentContainer.viewContext)
            let newUserDetail = UserDetail(context: session.persistentContainer.viewContext)
            
            oldUserDetail.followerUserIDs = [1, 2, 3, 4, 5].map { String($0) }
            oldUserDetail.followerUsersCount = 6
            newUserDetail.followerUserIDs = [2, 3, 6].map { String($0) }
            newUserDetail.followerUsersCount = 3
            
            XCTAssertEqual(Session.followerUserChanges(oldUserDetail: oldUserDetail, newUserDetail: newUserDetail).followerUsersCount, 1)
            XCTAssertEqual(Session.followerUserChanges(oldUserDetail: oldUserDetail, newUserDetail: newUserDetail).unfollowerUsersCount, 3)
        }
    }
    func testFollowerUserChangesUsingUserIDs() {
        withExtendedLifetime(Session(inMemory: true)) { session in
            let oldUserDetail = UserDetail(context: session.persistentContainer.viewContext)
            let newUserDetail = UserDetail(context: session.persistentContainer.viewContext)
            
            oldUserDetail.followerUserIDs = [1, 2, 3, 4, 5].map { String($0) }
            newUserDetail.followerUserIDs = [2, 3, 6].map { String($0) }
            
            XCTAssertEqual(Session.followerUserChanges(oldUserDetail: oldUserDetail, newUserDetail: newUserDetail).followerUsersCount, 1)
            XCTAssertEqual(Session.followerUserChanges(oldUserDetail: oldUserDetail, newUserDetail: newUserDetail).unfollowerUsersCount, 3)
        }
    }
    
    func testFollowerUserChangesUsingCount() {
        withExtendedLifetime(Session(inMemory: true)) { session in
            let oldUserDetail = UserDetail(context: session.persistentContainer.viewContext)
            let newUserDetail = UserDetail(context: session.persistentContainer.viewContext)
            
            oldUserDetail.followerUsersCount = 3
            newUserDetail.followerUsersCount = 5
            XCTAssertEqual(Session.followerUserChanges(oldUserDetail: oldUserDetail, newUserDetail: newUserDetail).followerUsersCount, 2)
            XCTAssertEqual(Session.followerUserChanges(oldUserDetail: oldUserDetail, newUserDetail: newUserDetail).unfollowerUsersCount, 0)
            
            oldUserDetail.followerUsersCount = 10
            newUserDetail.followerUsersCount = 7
            XCTAssertEqual(Session.followerUserChanges(oldUserDetail: oldUserDetail, newUserDetail: newUserDetail).followerUsersCount, 0)
            XCTAssertEqual(Session.followerUserChanges(oldUserDetail: oldUserDetail, newUserDetail: newUserDetail).unfollowerUsersCount, 3)
        }
    }
}
