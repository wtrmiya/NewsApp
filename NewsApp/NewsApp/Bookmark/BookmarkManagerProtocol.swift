//
//  BookmarkManagerProtocol.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/12.
//

import Foundation

protocol BookmarkManagerProtocol: AnyObject {
    func addBookmark(article: Article, userAccount: UserAccount) async throws -> Article?
    func deleteBookmark(article: Article, userAccount: UserAccount) async throws -> Article?
    func deleteBookmarks(articles: [Article], userAccount: UserAccount) async throws
    func getBookmarks(userAccount: UserAccount) async throws -> [Article]
}
