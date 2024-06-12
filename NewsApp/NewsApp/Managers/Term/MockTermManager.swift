//
//  MockTermManager.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/13.
//

import Foundation

final class MockTermManager: TermManagerProtocol {
    func getLatestTerm() async throws -> Term? {
        return Term(
            title: "NewsApp 利用規約",
            // swiftlint:disable:next line_length
            body: "第1条（適用）\n 本利用規約（以下、「本規約」といいます。）は、NewsApp（以下、「本アプリ」といいます。）の利用に関する条件を定めるものです。本アプリを利用する全てのユーザー（以下、「ユーザー」といいます。）は、本規約に同意した上で本アプリを利用するものとします。",
            // swiftlint:disable:previous line_length
            effectiveDate: Date(),
            createdAt: Date()
        )
    }
}
