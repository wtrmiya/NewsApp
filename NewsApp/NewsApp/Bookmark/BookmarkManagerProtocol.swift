//
//  BookmarkManagerProtocol.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/12.
//

import Foundation

protocol BookmarkManagerProtocol: AnyObject {
    func addBookmark(article: Article, user: UserAccount) async throws -> Article?
    func deleteBookmark(article: Article, user: UserAccount) async throws -> Article?
    func deleteBookmarks(articles: [Article], uid: String) async throws
    func getBookmarks(user: UserAccount) async throws -> [Article]
}
