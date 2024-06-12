//
//  BookmarkManagerProtocol.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/12.
//

import Foundation

protocol BookmarkManagerProtocol: AnyObject {
    func addBookmark(article: Article, uid: String) async throws -> Article?
    func removeBookmark(article: Article, uid: String) async throws -> Article?
}
