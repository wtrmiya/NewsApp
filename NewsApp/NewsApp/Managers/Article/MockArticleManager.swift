//
//  MockArticleManager.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/11.
//

import Foundation

final class MockArticleManagerVarid: ArticleManagerProtocol {
    func getArticlesByCategory(category: ArticleCategory) async throws -> [Article] {
        return [
            Article(
                source: ArticleSource(name: "Example.com"),
                author: nil,
                title: "サンプル記事 タイトル 先発出場で二塁打もチーム敗れる | Example | サンプル記事 - example.com",
                description: "サンプル記事、ドジャースの選手は9日、ヤンキースとの3連戦の最終戦に先発出場し、ツーベースヒット1本を打ちましたが、…",
                url: "https://www.example.com/news/html/20240610/k10014475991000.html",
                urlToImage: "https://www.example.com/news/html/20240610/sample_image_01.jpg",
                publishedAt: "2024-06-10T04:12:02Z",
                bookmarked: false,
                documentId: nil,
                bookmarkedAt: nil
            ),
            Article(
                source: ArticleSource(name: "Example.com"),
                author: nil,
                title: "サンプル記事 タイトル 先発出場で二塁打もチーム敗れる | Example | サンプル記事 - example.com",
                description: "サンプル記事、ドジャースの選手は9日、ヤンキースとの3連戦の最終戦に先発出場し、ツーベースヒット1本を打ちましたが、…",
                url: "https://www.example.com/news/html/20240610/k10014475991000.html",
                urlToImage: "https://www.example.com/news/html/20240610/sample_image_01.jpg",
                publishedAt: "2024-06-10T04:12:02Z",
                bookmarked: false,
                documentId: nil,
                bookmarkedAt: nil
            )
        ]
    }
    
    func getArticlesBySearchText(text: String) async throws -> [Article] {
        return []
    }
}

final class MockArticleManagerInvalidAPIKey: ArticleManagerProtocol {
    func getArticlesByCategory(category: ArticleCategory) async throws -> [Article] {
        throw NetworkError.invalidAPIKey
    }
    
    func getArticlesBySearchText(text: String) async throws -> [Article] {
        return []
    }
}

final class MockArticleManagerInvalidResponse: ArticleManagerProtocol {
    func getArticlesByCategory(category: ArticleCategory) async throws -> [Article] {
        throw NetworkError.invalidResponse
    }
    
    func getArticlesBySearchText(text: String) async throws -> [Article] {
        return []
    }
}

final class MockArticleManagerOtherError: ArticleManagerProtocol {
    func getArticlesByCategory(category: ArticleCategory) async throws -> [Article] {
        throw AuthError.unknownError(errorMessage: "Unknown")
    }
    
    func getArticlesBySearchText(text: String) async throws -> [Article] {
        return []
    }
}
