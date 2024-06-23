//
//  ArticleManager.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/11.
//

import Foundation

final class ArticleManager {
    static let shared = ArticleManager()
    private init() {
        Task {
            do {
                try await fetchDefaultArticles()
            } catch {
                print(error)
            }
        }
    }
    
    private var articles: [ArticleCategory: [Article]] = [:]
}

private extension ArticleManager {
    private func fetchDefaultArticles() async throws {
        do {
            articles[.general] = try await getArticlesByCategory(category: .general)
        } catch {
            print(error)
        }
    }
}

extension ArticleManager: ArticleManagerProtocol {
    func getArticlesByCategory(category: ArticleCategory) async throws -> [Article] {
        guard let specifiedCategoryArticles = articles[category]
        else {
            return []
        }
        
        guard specifiedCategoryArticles.isEmpty
        else {
            return specifiedCategoryArticles
        }
        
        guard let apiKey = APIKeyManager.shared.apiKey(for: "API_KEY_NewsAPI")
        else {
            throw NetworkError.invalidAPIKey
        }
        
        let url = URL(string: "https://newsapi.org/v2/top-headlines?country=jp&category=\(category.rawValue)")!
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-Api-Key")
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200
            else {
                throw NetworkError.invalidResponse
            }
            
            let articleResponse = try JSONDecoder().decode(ArticleResponse.self, from: data)
            return articleResponse.articles
        } catch {
            throw error
        }
    }
    
    func getArticlesBySearchText(text: String) async throws -> [Article] {
        guard let apiKey = APIKeyManager.shared.apiKey(for: "API_KEY_NewsAPI")
        else {
            throw NetworkError.invalidAPIKey
        }
        
        let encodedURLString = "https://newsapi.org/v2/everything?q=\(text)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: encodedURLString)!
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-Api-Key")
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200
            else {
                throw NetworkError.invalidResponse
            }
            
            let articleResponse = try JSONDecoder().decode(ArticleResponse.self, from: data)
            
            return articleResponse.articles
        } catch {
            throw error
        }
    }
}
