//
//  NewsAppAccountManagerIntegrationTests.swift
//  NewsAppAccountManagerIntegrationTests
//
//  Created by Wataru Miyakoshi on 2024/08/04.
//

import XCTest
@testable import NewsApp
import FirebaseAuth

final class NewsAppAccountManagerIntegrationTests: XCTestCase {
    func test_サインアップする() {
        let expectation = XCTestExpectation()
        
        // ダミーユーザ作成
        let email = "hello@example.com"
        let password = "password"
        let displayName = "testuser"
        
        let sut = AccountManager.shared
        
        Task {
            do {
                try await sut.signUp(email: email, password: password, displayName: displayName)
                expectation.fulfill()
            } catch {
                XCTFail("Exception throwed")
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
        guard let userAccount = sut.userAccount
        else {
            XCTFail("userAccount is nil")
            return
        }
        
        XCTAssertEqual(userAccount.email, email)
        
        // Tear Down
        let expectation2 = XCTestExpectation()
        Task {
            do {
                try await sut.deleteAccount(email: email, password: password)
                expectation2.fulfill()
            } catch {
                XCTFail("Exception throwed")
            }
        }
        wait(for: [expectation2], timeout: 5.0)
    }
    
    func test_サインアウトする() {
        // ダミーユーザ作成
        let email = "hello@example.com"
        let password = "password"
        let displayName = "testuser"
        
        let sut = AccountManager.shared
        
        let expectation = XCTestExpectation(description: "user should be created")
        Task {
            do {
                try await sut.signUp(email: email, password: password, displayName: displayName)
                expectation.fulfill()
            } catch {
                XCTFail("Exception throwed: \(error.localizedDescription)")
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
        guard sut.userAccount != nil
        else {
            XCTFail("userAccount is nil")
            return
        }
        
        do {
            try sut.signOut()
        } catch {
            XCTFail("Exception throwed: \(error.localizedDescription)")
        }
        
        let userAccountSignOuted = sut.userAccount
        XCTAssertNil(userAccountSignOuted)
        
        // Tear Down
        let expectation2 = XCTestExpectation(description: "user should be deleted")
        Task {
            do {
                try await sut.signIn(email: email, password: password)
                try await sut.deleteAccount(email: email, password: password)
                expectation2.fulfill()
            } catch {
                XCTFail("Exception throwed: \(error.localizedDescription)")
            }
        }
        wait(for: [expectation2], timeout: 5.0)
    }
    
    func test_サインインする() {
        // ダミーユーザ作成
        let email = "hello@example.com"
        let password = "password"
        let displayName = "testuser"
        
        let sut = AccountManager.shared
        
        let expectation = XCTestExpectation(description: "user should be created")
        Task {
            do {
                try await sut.signUp(email: email, password: password, displayName: displayName)
                expectation.fulfill()
            } catch {
                XCTFail("Exception throwed: \(error.localizedDescription)")
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
        guard sut.userAccount != nil
        else {
            XCTFail("userAccount is nil")
            return
        }
        
        do {
            try sut.signOut()
        } catch {
            XCTFail("Exception throwed: \(error.localizedDescription)")
        }
        
        let expectationSignIn = XCTestExpectation(description: "user should be signed in")
        Task {
            do {
                try await sut.signIn(email: email, password: password)
                expectationSignIn.fulfill()
            } catch {
                XCTFail("Exception throwed: \(error.localizedDescription)")
            }
        }
        
        wait(for: [expectationSignIn], timeout: 5.0)
        
        guard let userAccount = sut.userAccount
        else {
            XCTFail("userAccount is nil")
            return
        }
        
        XCTAssertEqual(userAccount.email, email)

        // Tear Down
        let expectationTearDown = XCTestExpectation(description: "user should be deleted")
        Task {
            do {
                try await sut.deleteAccount(email: email, password: password)
                expectationTearDown.fulfill()
            } catch {
                XCTFail("Exception throwed: \(error.localizedDescription)")
            }
        }
        wait(for: [expectationTearDown], timeout: 5.0)
    }
    
    func test_ユーザの表示名を変更する() {
        // ダミーユーザ作成
        let email = "hello@example.com"
        let password = "password"
        let displayName = "testuser"
        
        let sut = AccountManager.shared
        
        let expectation = XCTestExpectation(description: "user should be created")
        Task {
            do {
                try await sut.signUp(email: email, password: password, displayName: displayName)
                expectation.fulfill()
            } catch {
                XCTFail("Exception throwed: \(error.localizedDescription)")
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
        guard sut.userAccount != nil
        else {
            XCTFail("userAccount is nil")
            return
        }
        
        let expectationUpdateDisplayName = XCTestExpectation(description: "display name should be updated")
        let newDisplayName = "NewDisplayName"
        Task {
            do {
                try await sut.updateDisplayName(displayName: newDisplayName)
                try sut.signOut()
                try await sut.signIn(email: email, password: password)
                expectationUpdateDisplayName.fulfill()
            } catch {
                XCTFail("Exception throwed: \(error.localizedDescription)")
            }
        }
        
        wait(for: [expectationUpdateDisplayName], timeout: 5.0)
        
        guard let updatedUserAccount = sut.userAccount
        else {
            XCTFail("userAccount is nil")
            return
        }

        XCTAssertEqual(updatedUserAccount.displayName, newDisplayName)

        // Tear Down
        let expectationTearDown = XCTestExpectation(description: "user should be deleted")
        Task {
            do {
                try await sut.deleteAccount(email: email, password: password)
                expectationTearDown.fulfill()
            } catch {
                XCTFail("Exception throwed: \(error.localizedDescription)")
            }
        }
        wait(for: [expectationTearDown], timeout: 5.0)       
    }
    
    func test_ユーザアカウントを削除する() {
        // ダミーユーザ作成
        let email = "hello@example.com"
        let password = "password"
        let displayName = "testuser"
        
        let sut = AccountManager.shared
        
        let expectation = XCTestExpectation(description: "user should be created")
        Task {
            do {
                try await sut.signUp(email: email, password: password, displayName: displayName)
                expectation.fulfill()
            } catch {
                XCTFail("Exception throwed: \(error.localizedDescription)")
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
        guard sut.userAccount != nil
        else {
            XCTFail("userAccount is nil")
            return
        }
        
        let expectationDeleteAccount = XCTestExpectation(description: "user should be deleted")
        Task {
            do {
                try await sut.deleteAccount(email: email, password: password)
                expectationDeleteAccount.fulfill()
            } catch {
                XCTFail("Exception throwed: \(error.localizedDescription)")
            }
        }
        wait(for: [expectationDeleteAccount], timeout: 5.0)
        
        
        let expectationSignIn = XCTestExpectation(description: "sign in should be failed")
        Task {
            do {
                try await sut.signIn(email: email, password: password)
            } catch {
                XCTAssertEqual(error as? AccountManagerError, AccountManagerError.unknownAuthError)
                expectationSignIn.fulfill()
            }
        }
        
        wait(for: [expectationSignIn], timeout: 5.0)
    }
}
