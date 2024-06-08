//
//  SignInViewModelTests.swift
//  NewsAppTests
//
//  Created by Wataru Miyakoshi on 2024/06/08.
//

import XCTest
@testable import NewsApp

final class SignInViewModelTests: XCTestCase {
    @MainActor
    func test_問題なくサインインを実行できた場合エラーメッセージが生成されないこと() {
        let accountManager = MockAccountManager()
        let sut = SignInViewModel(accountManager: accountManager)
        
        // ダミーユーザ情報
        let email = "hello@example.com"
        let password = "password"
        let displayName = "testuser"
        
        // ユーザ作成
        let expectation1 = XCTestExpectation()
        
        Task {
            do {
                try await accountManager.signUp(email: email, password: password, displayName: displayName)
                expectation1.fulfill()
                print("signUp completed.")
            } catch {
                print(error)
            }
        }
        
        wait(for: [expectation1], timeout: 5.0)

        // 一旦サインアウト
        let expectation2 = XCTestExpectation()
        
        do {
            try accountManager.signOut()
            expectation2.fulfill()
            print("signOut completed.")
        } catch {
            print(error)
        }
        
        wait(for: [expectation2], timeout: 5.0)
        
        // テスト
        let expectation3 = XCTestExpectation()

        Task {
            sut.email = email
            sut.password = password
            await sut.signIn()
            expectation3.fulfill()
        }
        wait(for: [expectation3], timeout: 5.0)
        
        XCTAssertNil(sut.errorMessage)
    }
    
    @MainActor
    func test_Emailの形式が誤っていればその旨のエラーメッセージを生成する() {
        let accountManager = MockAccountManager()
        let sut = SignInViewModel(accountManager: accountManager)
        
        // ダミーユーザ情報
        let email = "hello@example.com"
        let password = "password"
        let displayName = "testuser"
        
        // ユーザ作成
        let expectation1 = XCTestExpectation()
        
        Task {
            do {
                try await accountManager.signUp(email: email, password: password, displayName: displayName)
                expectation1.fulfill()
                print("signUp completed.")
            } catch {
                print(error)
            }
        }
        
        wait(for: [expectation1], timeout: 5.0)

        // 一旦サインアウト
        let expectation2 = XCTestExpectation()
        
        do {
            try accountManager.signOut()
            expectation2.fulfill()
            print("signOut completed.")
        } catch {
            print(error)
        }
        
        wait(for: [expectation2], timeout: 5.0)
        
        // テスト
        let expectation3 = XCTestExpectation()

        Task {
            sut.email = "invalid_email"
            sut.password = password
            await sut.signIn()
            expectation3.fulfill()
        }
        wait(for: [expectation3], timeout: 5.0)
        
        XCTAssertEqual(sut.errorMessage, "invalidEmail")
    }
    
    @MainActor
    func test_Emailが未登録であればその旨のエラーメッセージを生成する() {
        let accountManager = MockAccountManager()
        let sut = SignInViewModel(accountManager: accountManager)
        
        // ダミーユーザ情報
        let email = "hello@example.com"
        let password = "password"
        let displayName = "testuser"
        
        // ユーザ作成
        let expectation1 = XCTestExpectation()
        
        Task {
            do {
                try await accountManager.signUp(email: email, password: password, displayName: displayName)
                expectation1.fulfill()
                print("signUp completed.")
            } catch {
                print(error)
            }
        }
        
        wait(for: [expectation1], timeout: 5.0)

        // 一旦サインアウト
        let expectation2 = XCTestExpectation()
        
        do {
            try accountManager.signOut()
            expectation2.fulfill()
            print("signOut completed.")
        } catch {
            print(error)
        }
        
        wait(for: [expectation2], timeout: 5.0)
        
        // テスト
        let expectation3 = XCTestExpectation()

        Task {
            sut.email = "world@example.com"
            sut.password = password
            await sut.signIn()
            expectation3.fulfill()
        }
        wait(for: [expectation3], timeout: 5.0)
        
        XCTAssertEqual(sut.errorMessage, "invalidEmail")
    }
    
    @MainActor
    func test_パスワードが誤っていればその旨のエラーメッセージを生成する() {
        let accountManager = MockAccountManager()
        let sut = SignInViewModel(accountManager: accountManager)
        
        // ダミーユーザ情報
        let email = "hello@example.com"
        let password = "password"
        let displayName = "testuser"
        
        // ユーザ作成
        let expectation1 = XCTestExpectation()
        
        Task {
            do {
                try await accountManager.signUp(email: email, password: password, displayName: displayName)
                expectation1.fulfill()
                print("signUp completed.")
            } catch {
                print(error)
            }
        }
        
        wait(for: [expectation1], timeout: 5.0)

        // 一旦サインアウト
        let expectation2 = XCTestExpectation()
        
        do {
            try accountManager.signOut()
            expectation2.fulfill()
            print("signOut completed.")
        } catch {
            print(error)
        }
        
        wait(for: [expectation2], timeout: 5.0)
        
        // テスト
        let expectation3 = XCTestExpectation()

        Task {
            sut.email = email
            sut.password = "wrong_password"
            await sut.signIn()
            expectation3.fulfill()
        }
        wait(for: [expectation3], timeout: 5.0)
        
        XCTAssertEqual(sut.errorMessage, "wrongPassword")
    }
}
