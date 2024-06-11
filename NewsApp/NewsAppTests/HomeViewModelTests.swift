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
            await sut.populateArticles()
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
            await sut.populateArticles()
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
            await sut.populateArticles()
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
            await sut.populateArticles()
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
}
