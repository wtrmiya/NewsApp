//
//  SignUpViewModelTests.swift
//  NewsAppTests
//
//  Created by Wataru Miyakoshi on 2024/06/07.
//

import XCTest
@testable import NewsApp

final class SignUpViewModelTests: XCTestCase {
    @MainActor
    func test_問題なくサインインを実行できた場合エラーメッセージが生成されないこと() {
        let expectation1 = XCTestExpectation()
        let sut = SignUpViewModel(
            accountManager: MockAccountManager(),
            userSettingsManager: MockUserSettingsManager(),
            userDataStoreManager: MockUserDataStoreManager()
        )
        
        sut.email = "hello@example.com"
        sut.password = "password"
        sut.displayName = "testuser"
        sut.passwordRepeated = "password"
        
        Task {
            await sut.signUp()
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 5.0)
        
        XCTAssertNil(sut.errorMessage)
    }

    @MainActor
    func test_Emailの形式が誤っていればその旨のエラーメッセージを生成する() {
        let expectation = XCTestExpectation()
        let sut = SignUpViewModel(
            accountManager: MockAccountManager(),
            userSettingsManager: MockUserSettingsManager(),
            userDataStoreManager: MockUserDataStoreManager()
        )
        sut.email = "hello"
        sut.password = "password"
        sut.displayName = "testuser"
        sut.passwordRepeated = "password"
        
        Task {
            await sut.signUp()
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        guard let errorMessage = sut.errorMessage
        else {
            XCTFail("errorMessage should not be nil")
            return
        }
        
        XCTAssertEqual(errorMessage, "invalidEmail")
    }
    
    @MainActor
    func test_パスワードが短すぎるときその旨のエラーメッセージを生成する() {
        let expectation = XCTestExpectation()
        let sut = SignUpViewModel(accountManager: MockAccountManager())
        sut.email = "hello@example.com"
        sut.password = "pass"
        sut.displayName = "testuser"
        sut.passwordRepeated = "password"
        
        Task {
            await sut.signUp()
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        guard let errorMessage = sut.errorMessage
        else {
            XCTFail("errorMessage should not be nil")
            return
        }
        
        XCTAssertEqual(errorMessage, "weakPassword")
    }
    
    @MainActor
    func test_既に登録されているEmailを登録しようとした場合にその旨のエラーメッセージを生成する() {
        let expectation1 = XCTestExpectation()
        let sut = SignUpViewModel(
            accountManager: MockAccountManager(),
            userSettingsManager: MockUserSettingsManager(),
            userDataStoreManager: MockUserDataStoreManager()
        )
        sut.email = "hello@example.com"
        sut.password = "password"
        sut.displayName = "testuser1"
        sut.passwordRepeated = "password"
        
        Task {
            await sut.signUp()
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 5.0)
        
        let expectation2 = XCTestExpectation()
        sut.email = "hello@example.com"
        sut.password = "password"
        sut.displayName = "testuser2"
        sut.passwordRepeated = "password"
        
        Task {
            await sut.signUp()
            expectation2.fulfill()
        }
        
        wait(for: [expectation2], timeout: 5.0)

        guard let errorMessage = sut.errorMessage
        else {
            XCTFail("errorMessage should not be nil")
            return
        }
        
        XCTAssertEqual(errorMessage, "emailAlreadyInUse")
    }
}
