//
//  MockBookmarkManager.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/12.
//

import Foundation

final class MockBookmarkManager: BookmarkManagerProtocol {
    func addBookmark(article: Article, uid: String) async throws -> Article? {
        guard article.bookmarked else { return nil }
        let updatedArticle = article.updateBookmarkedData(documentId: UUID().uuidString)
        return updatedArticle
    }
    
    func removeBookmark(article: Article, uid: String) async throws -> Article? {
        guard !article.bookmarked else { return nil }
        guard let bookmarkDocumentId = article.documentId else { return nil }
        let updatedArticle = article.updateBookmarkedData(documentId: nil)
        return updatedArticle
    }
}
