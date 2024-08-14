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
    func test_サインアップする() async {
        // ダミーユーザ作成
        let email = "hello@example.com"
        let password = "password"
        let displayName = "testuser"
        
        let sut = AccountManager.shared
        
        do {
            try await sut.signUp(email: email, password: password, displayName: displayName)
        } catch {
            XCTFail("Exception throwed")
        }
        
        guard let userAccount = sut.userAccount
        else {
            XCTFail("userAccount is nil")
            return
        }
        
        XCTAssertEqual(userAccount.email, email)
        
        // Tear Down
        do {
            try await sut.deleteAccount(email: email, password: password)
        } catch {
            XCTFail("Exception throwed")
        }
    }
    
    func test_サインアウトする() async {
        // ダミーユーザ作成
        let email = "hello@example.com"
        let password = "password"
        let displayName = "testuser"
        
        let sut = AccountManager.shared
        
        do {
            try await sut.signUp(email: email, password: password, displayName: displayName)
        } catch {
            XCTFail("Exception throwed: \(error.localizedDescription)")
        }
        
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
        do {
            try await sut.signIn(email: email, password: password)
            try await sut.deleteAccount(email: email, password: password)
        } catch {
            XCTFail("Exception throwed: \(error.localizedDescription)")
        }
    }

    func test_サインインする() async {
        // ダミーユーザ作成
        let email = "hello@example.com"
        let password = "password"
        let displayName = "testuser"
        
        let sut = AccountManager.shared
        
        do {
            try await sut.signUp(email: email, password: password, displayName: displayName)
        } catch {
            XCTFail("Exception throwed: \(error.localizedDescription)")
        }
                
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
        
        do {
            try await sut.signIn(email: email, password: password)
        } catch {
            XCTFail("Exception throwed: \(error.localizedDescription)")
        }
        
        guard let userAccount = sut.userAccount
        else {
            XCTFail("userAccount is nil")
            return
        }
        
        XCTAssertEqual(userAccount.email, email)

        // Tear Down
        do {
            try await sut.deleteAccount(email: email, password: password)
        } catch {
            XCTFail("Exception throwed: \(error.localizedDescription)")
        }
    }
    
    func test_ユーザの表示名を変更する() async {
        // ダミーユーザ作成
        let email = "hello@example.com"
        let password = "password"
        let displayName = "testuser"
        
        let sut = AccountManager.shared
        
        do {
            try await sut.signUp(email: email, password: password, displayName: displayName)
        } catch {
            XCTFail("Exception throwed: \(error.localizedDescription)")
        }
        
        guard sut.userAccount != nil
        else {
            XCTFail("userAccount is nil")
            return
        }
        
        let newDisplayName = "NewDisplayName"
        do {
            try await sut.updateDisplayName(displayName: newDisplayName)
            try sut.signOut()
            try await sut.signIn(email: email, password: password)
        } catch {
            XCTFail("Exception throwed: \(error.localizedDescription)")
        }
        
        guard let updatedUserAccount = sut.userAccount
        else {
            XCTFail("userAccount is nil")
            return
        }

        XCTAssertEqual(updatedUserAccount.displayName, newDisplayName)

        // Tear Down
        do {
            try await sut.deleteAccount(email: email, password: password)
        } catch {
            XCTFail("Exception throwed: \(error.localizedDescription)")
        }
    }

    func test_ユーザアカウントを削除する() async {
        // ダミーユーザ作成
        let email = "hello@example.com"
        let password = "password"
        let displayName = "testuser"
        
        let sut = AccountManager.shared
        
        do {
            try await sut.signUp(email: email, password: password, displayName: displayName)
        } catch {
            XCTFail("Exception throwed: \(error.localizedDescription)")
        }
        
        guard sut.userAccount != nil
        else {
            XCTFail("userAccount is nil")
            return
        }
        
        do {
            try await sut.deleteAccount(email: email, password: password)
        } catch {
            XCTFail("Exception throwed: \(error.localizedDescription)")
        }
        
        do {
            try await sut.signIn(email: email, password: password)
        } catch {
            XCTAssertEqual(error as? AccountManagerError, AccountManagerError.unknownAuthError)
        }
    }
}
