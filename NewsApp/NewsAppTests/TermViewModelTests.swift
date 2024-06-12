//
//  TermViewModelTests.swift
//  NewsAppTests
//
//  Created by Wataru Miyakoshi on 2024/06/13.
//

import XCTest
@testable import NewsApp

final class TermViewModelTests: XCTestCase {
    func test_利用規約を取得できること() {
        let sut = TermViewModel(termManager: MockTermManager())
        
        let expectation1 = XCTestExpectation()
        Task {
            await sut.populateLatestTerm()
            expectation1.fulfill()
        }
        wait(for: [expectation1], timeout: 5.0)
        
        let title = "NewsApp 利用規約"
        // swiftlint:disable:next line_length
        let body = "第1条（適用）\n 本利用規約（以下、「本規約」といいます。）は、NewsApp（以下、「本アプリ」といいます。）の利用に関する条件を定めるものです。本アプリを利用する全てのユーザー（以下、「ユーザー」といいます。）は、本規約に同意した上で本アプリを利用するものとします。"
        // swiftlint:disable:previous line_length
        
        XCTAssertEqual(sut.term.title, title)
        XCTAssertEqual(sut.term.body, body)
    }
}
