//
//  HomeViewModelTests.swift
//  NewsAppTests
//
//  Created by Wataru Miyakoshi on 2024/06/11.
//

import XCTest
@testable import NewsApp

final class HomeViewModelTests: XCTestCase {
    @MainActor
    func test_記事を取得すること() {
        let expectation = XCTestExpectation()
        let sut = HomeViewModel(
            articleManager: MockArticleManagerVarid(),
            bookmarkManager: MockBookmarkManager(),
            accountManager: MockAccountManager(),
            userDataSoreManager: MockUserDataStoreManager()
        )
        Task {
            await sut.populateDefaultArticles()
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        XCTAssertNotEqual(sut.articles.count, 0)
        XCTAssertNil(sut.errorMessage)
    }
    
    func test_アカウントマネージャから現在サインイン中のユーザ情報を取得できること() {
        // ダミーユーザ作成
        let email = "hello@example.com"
        let password = "password"
        let displayName = "testuser"
        
        let expectation = XCTestExpectation()
        let mockAccountManager = MockAccountManager()
        let sut = HomeViewModel(
            articleManager: MockArticleManagerVarid(),
            bookmarkManager: MockBookmarkManager(),
            accountManager: mockAccountManager,
            userDataSoreManager: MockUserDataStoreManager()
        )
        
        Task {
            try await mockAccountManager.signUp(email: email, password: password, displayName: displayName)
            try await mockAccountManager.signIn(email: email, password: password)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        let result = sut.isSignedIn
        XCTAssertEqual(result, true)
    }
    
    func test_現在選択されているカテゴリに対応した記事を取得できること() {
        // ダミーユーザ作成
        let email = "hello@example.com"
        let password = "password"
        let displayName = "testuser"
        
        let expectation1 = XCTestExpectation()
        let mockAccountManager = MockAccountManager()
        let sut = HomeViewModel(
            articleManager: MockArticleManagerVarid(),
            bookmarkManager: MockBookmarkManager(),
            accountManager: mockAccountManager,
            userDataSoreManager: MockUserDataStoreManager()
        )
        
        Task {
            try await mockAccountManager.signUp(email: email, password: password, displayName: displayName)
            try await mockAccountManager.signIn(email: email, password: password)
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 5.0)
        
        let expectation2 = XCTestExpectation()
        Task {
            await sut.populateArticles(of: .business)
            expectation2.fulfill()
        }
        
        wait(for: [expectation2], timeout: 5.0)
        
        XCTAssertEqual(sut.articles.count, 2)
    }

    // MARK: - toggleBookmark(articleIndex: Int) async
    func test_指定したインデックスの記事が非ブックマーク状態であればブックマークされた状態になること() {
        let sut = HomeViewModel(
            articleManager: MockArticleManagerVarid(),
            bookmarkManager: MockBookmarkManager(),
            accountManager: MockAccountManager(),
            userDataSoreManager: MockUserDataStoreManager()
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
        XCTAssertNotNil(sut.accountManager.userAccount)

        // ダミー記事登録
        let expectation2 = XCTestExpectation()
        Task {
            await sut.populateDefaultArticles()
            expectation2.fulfill()
        }
        
        wait(for: [expectation2], timeout: 5.0)
        XCTAssertGreaterThan(sut.articles.count, 0)
        let articleIndex = 0
        sut.articles[articleIndex].bookmarked = false
        let articleToCheck = sut.articles[articleIndex]
        
        // テスト
        let expectation3 = XCTestExpectation()
        Task {
            await sut.toggleBookmark(on: articleToCheck)
            expectation3.fulfill()
        }
        
        wait(for: [expectation3], timeout: 5.0)
        XCTAssertTrue(sut.articles[articleIndex].bookmarked)
        XCTAssertNotNil(sut.articles[articleIndex].documentId)
        XCTAssertNotNil(sut.articles[articleIndex].bookmarkedAt)
    }
    
    func test_指定したインデックスの記事がブックマーク済み状態であれば非ブックマーク状態になること() {
        let sut = HomeViewModel(
            articleManager: MockArticleManagerVarid(),
            bookmarkManager: MockBookmarkManager(),
            accountManager: MockAccountManager(),
            userDataSoreManager: MockUserDataStoreManager()
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
        XCTAssertNotNil(sut.accountManager.userAccount)

        // ダミー記事登録
        let expectation2 = XCTestExpectation()
        Task {
            await sut.populateDefaultArticles()
            expectation2.fulfill()
        }
        
        wait(for: [expectation2], timeout: 5.0)
        XCTAssertGreaterThan(sut.articles.count, 0)
        let articleIndex = 0
        sut.articles[articleIndex].bookmarked = true
        let articleToCheck = sut.articles[articleIndex]
        
        // テスト
        let expectation3 = XCTestExpectation()
        Task {
            await sut.toggleBookmark(on: articleToCheck)
            expectation3.fulfill()
        }
        
        wait(for: [expectation3], timeout: 5.0)
        XCTAssertFalse(sut.articles[articleIndex].bookmarked)
        XCTAssertNil(sut.articles[articleIndex].documentId)
        XCTAssertNil(sut.articles[articleIndex].bookmarkedAt)
    }
}
