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
        let sut = HomeViewModel(articleManager: MockArticleManagerVarid())
        Task {
            await sut.populateDefaultArticles()
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        XCTAssertNotEqual(sut.articles.count, 0)
        XCTAssertNil(sut.errorMessage)
    }
    
    @MainActor
    func test_APIキー誤りの例外が発生した場合その旨のエラーメッセージが生成されること() {
        let expectation = XCTestExpectation()
        let sut = HomeViewModel(articleManager: MockArticleManagerInvalidAPIKey())
        Task {
            await sut.populateDefaultArticles()
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(sut.articles.count, 0)
        guard let errorMessage = sut.errorMessage
        else {
            XCTFail("errorMessage should be not nil")
            return
        }
        XCTAssertEqual(errorMessage, "invalidAPIKey")
    }
    
    @MainActor
    func test_レスポンス200以外が返却されてきた場合その旨のエラーメッセージが生成されること() {
        let expectation = XCTestExpectation()
        let sut = HomeViewModel(articleManager: MockArticleManagerInvalidResponse())
        Task {
            await sut.populateDefaultArticles()
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(sut.articles.count, 0)
        guard let errorMessage = sut.errorMessage
        else {
            XCTFail("errorMessage should be not nil")
            return
        }
        XCTAssertEqual(errorMessage, "invalidResponse")
    }
    
    @MainActor
    func test_想定していない例外が発生した場合その旨のエラーメッセージが生成されること() {
        let expectation = XCTestExpectation()
        let sut = HomeViewModel(articleManager: MockArticleManagerOtherError())
        Task {
            await sut.populateDefaultArticles()
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(sut.articles.count, 0)
        guard let errorMessage = sut.errorMessage
        else {
            XCTFail("errorMessage should be not nil")
            return
        }
        // swiftlint:disable:next line_length
        XCTAssertEqual(errorMessage, "Sorry, something wrong. error: The operation couldn’t be completed. (NewsApp.AuthError error 1.)")
        // swiftlint:disable:previous line_length
    }

    // MARK: - toggleBookmark(articleIndex: Int) async
    func test_指定したインデックスの記事が非ブックマーク状態であればブックマークされた状態になること() {
        let sut = HomeViewModel(
            articleManager: MockArticleManagerVarid(),
            bookmarkManager: MockBookmarkManager(),
            accountManager: MockAccountManager()
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
            accountManager: MockAccountManager()
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
