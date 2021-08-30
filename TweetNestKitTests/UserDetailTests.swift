//
//  UserDetailTests+BackgroundTask.swift
//  UserDetailTests+BackgroundTask
//
//  Created by Jaehong Kang on 2021/08/30.
//

import XCTest
@testable import TweetNestKit

class UserDetailTests: XCTestCase {
    func testFollowingUserChanges() {
        withExtendedLifetime(Session(inMemory: true)) { session in
            let oldUserDetail = UserDetail(context: session.persistentContainer.viewContext)
            let newUserDetail = UserDetail(context: session.persistentContainer.viewContext)
            
            oldUserDetail.followingUserIDs = [1, 2, 3, 4, 5].map { String($0) }
            oldUserDetail.followingUsersCount = 6
            newUserDetail.followingUserIDs = [2, 3, 6].map { String($0) }
            newUserDetail.followingUsersCount = 3
            
            XCTAssertEqual(newUserDetail.followingUserChanges(from: oldUserDetail).followingUsersCount, 1)
            XCTAssertEqual(newUserDetail.followingUserChanges(from: oldUserDetail).unfollowingUsersCount, 3)
        }
    }
    
    func testFollowingUserChangesUsingUserIDs() {
        withExtendedLifetime(Session(inMemory: true)) { session in
            let oldUserDetail = UserDetail(context: session.persistentContainer.viewContext)
            let newUserDetail = UserDetail(context: session.persistentContainer.viewContext)
            
            oldUserDetail.followingUserIDs = [1, 2, 3, 4, 5].map { String($0) }
            newUserDetail.followingUserIDs = [2, 3, 6].map { String($0) }
            
            XCTAssertEqual(newUserDetail.followingUserChanges(from: oldUserDetail).followingUsersCount, 1)
            XCTAssertEqual(newUserDetail.followingUserChanges(from: oldUserDetail).unfollowingUsersCount, 3)
        }
    }
    
    func testFollowingUserChangesUsingUserIDsWithoutOldUserDetail() {
        withExtendedLifetime(Session(inMemory: true)) { session in
            let newUserDetail = UserDetail(context: session.persistentContainer.viewContext)
            
            newUserDetail.followingUserIDs = [2, 3, 6].map { String($0) }
            
            XCTAssertEqual(newUserDetail.followingUserChanges(from: nil).followingUsersCount, 3)
            XCTAssertEqual(newUserDetail.followingUserChanges(from: nil).unfollowingUsersCount, 0)
        }
    }
    
    func testFollowingUserChangesUsingCount() {
        withExtendedLifetime(Session(inMemory: true)) { session in
            let oldUserDetail = UserDetail(context: session.persistentContainer.viewContext)
            let newUserDetail = UserDetail(context: session.persistentContainer.viewContext)
            
            oldUserDetail.followingUsersCount = 3
            newUserDetail.followingUsersCount = 5
            XCTAssertEqual(newUserDetail.followingUserChanges(from: oldUserDetail).followingUsersCount, 2)
            XCTAssertEqual(newUserDetail.followingUserChanges(from: oldUserDetail).unfollowingUsersCount, 0)
            
            oldUserDetail.followingUsersCount = 10
            newUserDetail.followingUsersCount = 7
            XCTAssertEqual(newUserDetail.followingUserChanges(from: oldUserDetail).followingUsersCount, 0)
            XCTAssertEqual(newUserDetail.followingUserChanges(from: oldUserDetail).unfollowingUsersCount, 3)
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
            
            XCTAssertEqual(newUserDetail.followerUserChanges(from: oldUserDetail).followerUsersCount, 1)
            XCTAssertEqual(newUserDetail.followerUserChanges(from: oldUserDetail).unfollowerUsersCount, 3)
        }
    }
    
    func testFollowerUserChangesUsingUserIDs() {
        withExtendedLifetime(Session(inMemory: true)) { session in
            let oldUserDetail = UserDetail(context: session.persistentContainer.viewContext)
            let newUserDetail = UserDetail(context: session.persistentContainer.viewContext)
            
            oldUserDetail.followerUserIDs = [1, 2, 3, 4, 5].map { String($0) }
            newUserDetail.followerUserIDs = [2, 3, 6].map { String($0) }
            
            XCTAssertEqual(newUserDetail.followerUserChanges(from: oldUserDetail).followerUsersCount, 1)
            XCTAssertEqual(newUserDetail.followerUserChanges(from: oldUserDetail).unfollowerUsersCount, 3)
        }
    }
    
    func testFollowerUserChangesUsingUserIDsWithoutOldUserDetail() {
        withExtendedLifetime(Session(inMemory: true)) { session in
            let newUserDetail = UserDetail(context: session.persistentContainer.viewContext)
            
            newUserDetail.followerUserIDs = [2, 3, 6].map { String($0) }
            
            XCTAssertEqual(newUserDetail.followerUserChanges(from: nil).followerUsersCount, 3)
            XCTAssertEqual(newUserDetail.followerUserChanges(from: nil).unfollowerUsersCount, 0)
        }
    }
    
    func testFollowerUserChangesUsingCount() {
        withExtendedLifetime(Session(inMemory: true)) { session in
            let oldUserDetail = UserDetail(context: session.persistentContainer.viewContext)
            let newUserDetail = UserDetail(context: session.persistentContainer.viewContext)
            
            oldUserDetail.followerUsersCount = 3
            newUserDetail.followerUsersCount = 5
            XCTAssertEqual(newUserDetail.followerUserChanges(from: oldUserDetail).followerUsersCount, 2)
            XCTAssertEqual(newUserDetail.followerUserChanges(from: oldUserDetail).unfollowerUsersCount, 0)
            
            oldUserDetail.followerUsersCount = 10
            newUserDetail.followerUsersCount = 7
            XCTAssertEqual(newUserDetail.followerUserChanges(from: oldUserDetail).followerUsersCount, 0)
            XCTAssertEqual(newUserDetail.followerUserChanges(from: oldUserDetail).unfollowerUsersCount, 3)
        }
    }
}
