//
//  DrawerViewModelTests.swift
//  NewsAppTests
//
//  Created by Wataru Miyakoshi on 2024/06/13.
//

import XCTest
@testable import NewsApp

final class DrawerViewModelTests: XCTestCase {
    func test_サインイン時にユーザ情報を取得できること() {
        let mockAccountManager = MockAccountManager()
        let sut = DrawerViewModel(accountManager: mockAccountManager)
        
        // ダミーユーザ作成
        let email = "hello@example.com"
        let password = "password"
        let displayName = "testuser"

        let expectation1 = XCTestExpectation()
        Task {
            do {
                try await mockAccountManager.signUp(email: email, password: password, displayName: displayName)
                expectation1.fulfill()
                print("signUp completed.")
            } catch {
                print(error)
            }
        }
        wait(for: [expectation1], timeout: 5.0)
        XCTAssertNotNil(sut.sidnedInUser)
    }
    
    func test_サインアウト時にユーザ情報を取得できないこと() {
        let sut = DrawerViewModel(accountManager: MockAccountManager())
        XCTAssertNil(sut.sidnedInUser)
    }
    
    func test_サインアウトできること() {
        let mockAccountManager = MockAccountManager()
        let sut = DrawerViewModel(accountManager: mockAccountManager)
        
        // ダミーユーザ作成
        let email = "hello@example.com"
        let password = "password"
        let displayName = "testuser"

        let expectation1 = XCTestExpectation()
        Task {
            do {
                try await mockAccountManager.signUp(email: email, password: password, displayName: displayName)
                expectation1.fulfill()
                print("signUp completed.")
            } catch {
                print(error)
            }
        }
        wait(for: [expectation1], timeout: 5.0)
        XCTAssertNotNil(sut.sidnedInUser)
        
        sut.signOut()
        XCTAssertNil(sut.sidnedInUser)
    }
}
