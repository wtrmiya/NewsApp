//
//  HomeViewModel.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/11.
//

import Foundation

struct ArticleResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}

struct Article: Codable {
    let source: ArticleSource
    let author: String
    let title: String
    let description: String
    let url: String
    let urlToImage: String
    let publishedAt: String
}

struct ArticleSource: Codable {
    let name: String
}

protocol ArticleManagerProtocol {
    func getGeneralArticles() async throws -> [Article]
}

enum NetworkError: Error {
    case invalidResponse
    case invalidData
    case failedInJSONSerialization
}

final class HomeViewModel: ObservableObject {
    @Published var articles: [Article] = []
    
    @Published var errorMessage: String?
    
    let articleManager: ArticleManagerProtocol
    
    init(articleManager: ArticleManagerProtocol = ArticleManager.shared) {
        self.articleManager = articleManager
    }
    
    @MainActor
    func populateArticles() async {
        do {
            let articles = try await articleManager.getGeneralArticles()
            self.articles = articles
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
