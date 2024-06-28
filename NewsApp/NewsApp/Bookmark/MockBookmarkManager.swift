//
//  MockBookmarkManager.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/12.
//

import Foundation

final class MockBookmarkManager: BookmarkManagerProtocol {
    func addBookmark(article: Article, user: UserAccount) async throws -> Article? {
        guard user.userDataStoreDocumentId != nil else { return nil }
        guard article.bookmarked else { return nil }
        let updatedArticle = article.updateBookmarkedData(documentId: UUID().uuidString)
        return updatedArticle
    }
    
    func deleteBookmark(article: Article, user: UserAccount) async throws -> Article? {
        guard user.userDataStoreDocumentId != nil else { return nil }
        guard !article.bookmarked else { return nil }
        guard article.documentId != nil else { return nil }
        let updatedArticle = article.updateBookmarkedData(documentId: nil)
        return updatedArticle
    }
    
    func deleteBookmarks(articles: [Article], user: UserAccount) async throws {
        guard user.userDataStoreDocumentId != nil else { return }
    }
    
    func getBookmarks(user: UserAccount) async throws -> [Article] {
        guard user.userDataStoreDocumentId != nil else { return [] }
        return [
            Article(
                source: ArticleSource(name: "Example.com"),
                author: nil,
                title: "サンプル記事 タイトル 先発出場で二塁打もチーム敗れる | Example | サンプル記事 - example.com",
                description: "サンプル記事、ドジャースの選手は9日、ヤンキースとの3連戦の最終戦に先発出場し、ツーベースヒット1本を打ちましたが、…",
                url: "https://www.example.com/news/html/20240610/k10014475991000.html",
                urlToImage: "https://www.example.com/news/html/20240610/sample_image_01.jpg",
                publishedAt: "2024-06-10T04:12:02Z",
                bookmarked: true,
                documentId: UUID().uuidString,
                bookmarkedAt: Date()
            ),
            Article(
                source: ArticleSource(name: "Example.com"),
                author: nil,
                title: "サンプル記事 タイトル 先発出場で二塁打もチーム敗れる | Example | サンプル記事 - example.com",
                description: "サンプル記事、ドジャースの選手は9日、ヤンキースとの3連戦の最終戦に先発出場し、ツーベースヒット1本を打ちましたが、…",
                url: "https://www.example.com/news/html/20240610/k10014475991000.html",
                urlToImage: "https://www.example.com/news/html/20240610/sample_image_01.jpg",
                publishedAt: "2024-06-10T04:12:02Z",
                bookmarked: true,
                documentId: UUID().uuidString,
                bookmarkedAt: Date()
            )
        ]
    }
}
