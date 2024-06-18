//
//  BookmarkViewModelTests.swift
//  NewsAppTests
//
//  Created by Wataru Miyakoshi on 2024/06/13.
//

import XCTest
@testable import NewsApp

final class BookmarkViewModelTests: XCTestCase {
    func test_ブックマークを取得できること() {
        let sut = BookmarkViewModel(
            accountManager: MockAccountManager(),
            bookmarkManager: MockBookmarkManager(),
            userDataStoreManager: MockUserDataStoreManager()
        )
        
        // ダミーユーザ作成
        let email = "hello@example.com"
        let password = "password"
        let displayName = "testuser"

        let expectation1 = XCTestExpectation()
        Task {
            do {
                try await sut.accountManager.signUp(email: email, password: password, displayName: displayName)
                expectation1.fulfill()
                print("signUp completed.")
            } catch {
                print(error)
            }
        }
        wait(for: [expectation1], timeout: 5.0)
        XCTAssertNotNil(sut.accountManager.user)

        // テスト
        let expectation2 = XCTestExpectation()
        Task {
            await sut.populateBookmarkedArticles()
            expectation2.fulfill()
        }
        
        wait(for: [expectation2], timeout: 5.0)
        XCTAssertGreaterThan(sut.articles.count, 0)
        let articleIndex = 0
        XCTAssertTrue(sut.articles[articleIndex].bookmarked)
        XCTAssertNotNil(sut.articles[articleIndex].documentId)
        XCTAssertNotNil(sut.articles[articleIndex].bookmarkedAt)
    }
}
