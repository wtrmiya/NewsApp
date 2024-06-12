//
//  ArticleManagerProtocol.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/12.
//

import Foundation

protocol ArticleManagerProtocol {
    func getGeneralArticles() async throws -> [Article]
}
