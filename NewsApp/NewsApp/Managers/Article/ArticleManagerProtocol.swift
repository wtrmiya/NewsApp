//
//  ArticleManagerProtocol.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/12.
//

import Foundation

protocol ArticleManagerProtocol {
    func getArticlesByCategory(category: ArticleCategory) async throws -> [Article]
    func getArticlesBySearchText(text: String) async throws -> [Article]
}
