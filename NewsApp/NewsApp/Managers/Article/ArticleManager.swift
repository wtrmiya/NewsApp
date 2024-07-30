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
        if let articlesByCategory = articles[category] {
            return articlesByCategory
        } else {
            do {
                let apiKey = try APIKeyManager.shared.apiKey(for: "API_KEY_NewsAPI")
                
                let url = URL(string: "https://newsapi.org/v2/top-headlines?country=jp&category=\(category.rawValue)")!
                var request = URLRequest(url: url)
                request.setValue(apiKey, forHTTPHeaderField: "X-Api-Key")
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200
                else {
                    throw NetworkError.invalidResponse
                }
                
                let articleResponse = try JSONDecoder().decode(ArticleResponse.self, from: data)
                articles[category] = articleResponse.articles
                return articleResponse.articles
            } catch {
                throw error
            }
        }
    }
    
    func getArticlesBySearchText(text: String) async throws -> [Article] {
        do {
            let apiKey = try APIKeyManager.shared.apiKey(for: "API_KEY_NewsAPI")
            
            let encodedURLString = "https://newsapi.org/v2/everything?q=\(text)"
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let url = URL(string: encodedURLString)!
            var request = URLRequest(url: url)
            request.setValue(apiKey, forHTTPHeaderField: "X-Api-Key")
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
