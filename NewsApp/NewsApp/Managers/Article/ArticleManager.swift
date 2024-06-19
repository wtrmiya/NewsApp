//
//  ArticleManager.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/11.
//

import Foundation

final class ArticleManager {
    static let shared = ArticleManager()
    private init() {}
}

extension ArticleManager: ArticleManagerProtocol {
    func getArticlesByCategory(category: ArticleCategory) async throws -> [Article] {
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
