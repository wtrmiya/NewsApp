//
//  Article.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/12.
//

import Foundation

struct ArticleResponse: Decodable {
    let status: String
    let totalResults: Int
    let articles: [Article]
    
    enum CodingKeys: String, CodingKey {
        case status, totalResults, articles
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.status = try container.decode(String.self, forKey: .status)
        self.totalResults = try container.decode(Int.self, forKey: .totalResults)
        var articlesArrayForType = try container.nestedUnkeyedContainer(forKey: .articles)
        var articles = [Article]()
        
        while !articlesArrayForType.isAtEnd {
            if let article = try? articlesArrayForType.decode(Article.self) {
                articles.append(article)
            } else {
                continue
            }
        }
        
        self.articles = articles
    }
}

struct Article: Decodable, Hashable {
    let source: ArticleSource
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
}

struct ArticleSource: Decodable, Hashable {
    let name: String
}
