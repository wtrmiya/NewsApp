//
//  ArticleManagerProtocol.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/12.
//

import Foundation

protocol ArticleManagerProtocol {
    func getArticles(category: ArticleCategory) async throws -> [Article]
}
