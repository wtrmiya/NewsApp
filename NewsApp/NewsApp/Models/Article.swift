//
//  Article.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/12.
//

import Foundation
import FirebaseFirestore
import CryptoKit

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

struct Article: Decodable, Hashable, Identifiable {
    var id: String
    let source: ArticleSource
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
    var bookmarked: Bool
    var documentId: String?
    var bookmarkedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case source, author, title, description, url, urlToImage, publishedAt
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.source = try container.decode(ArticleSource.self, forKey: .source)
        self.author = try container.decodeIfPresent(String.self, forKey: .author)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.url = try container.decode(String.self, forKey: .url)
        self.urlToImage = try container.decodeIfPresent(String.self, forKey: .urlToImage)
        self.publishedAt = try container.decode(String.self, forKey: .publishedAt)
        
        self.id = UUID().uuidString
        self.bookmarked = false
        self.documentId = nil
        self.bookmarkedAt = nil
    }
    
    init(
        id: String = UUID().uuidString,
        source: ArticleSource,
        author: String?,
        title: String,
        description: String?,
        url: String,
        urlToImage: String?,
        publishedAt: String,
        bookmarked: Bool,
        documentId: String?,
        bookmarkedAt: Date?
    ) {
        self.id = id
        self.source = source
        self.author = author
        self.title = title
        self.description = description
        self.url = url
        self.urlToImage = urlToImage
        self.publishedAt = publishedAt
        self.bookmarked = bookmarked
        self.documentId = documentId
        self.bookmarkedAt = bookmarkedAt
    }
    
    var bookmarkToggled: Article {
        return Article(
            id: self.id,
            source: self.source,
            author: self.author,
            title: self.title,
            description: self.description,
            url: self.url,
            urlToImage: self.urlToImage,
            publishedAt: self.publishedAt,
            bookmarked: !self.bookmarked,
            documentId: self.documentId,
            bookmarkedAt: self.bookmarkedAt
        )
    }
}

extension Article {
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "source": source.name,
            "author": author as Any,
            "title": title,
            "description": description as Any,
            "url": url,
            "urlToImage": urlToImage as Any,
            "publishedAt": publishedAt,
            "bookmarked": bookmarked,
            "bookmarkedAt": bookmarkedAt as Any
        ]
    }
    
    static func fromSnapshot(snapshot: QueryDocumentSnapshot) -> Article? {
        let dictionary = snapshot.data()
        guard let id = dictionary["id"] as? String,
              let source = dictionary["source"] as? String,
              let title = dictionary["title"] as? String,
              let url = dictionary["url"] as? String,
              let publishedAt = dictionary["publishedAt"] as? String,
              let bookmarked = dictionary["bookmarked"] as? Bool
        else {
            return nil
        }
        
        let author = dictionary["author"] as? String
        let description = dictionary["description"] as? String
        let urlToImage = dictionary["urlToImage"] as? String
        let bookmarkedAt = dictionary["bookmarkedAt"] as? Date

        return Article(
            id: id,
            source: ArticleSource(name: source),
            author: author,
            title: title,
            description: description,
            url: url,
            urlToImage: urlToImage,
            publishedAt: publishedAt,
            bookmarked: bookmarked,
            documentId: snapshot.documentID,
            bookmarkedAt: bookmarkedAt
        )
    }
    
    func updateBookmarkedData(documentId: String?) -> Article {
        return Article(
            id: self.id,
            source: self.source,
            author: self.author,
            title: self.title,
            description: self.description,
            url: self.url,
            urlToImage: self.urlToImage,
            publishedAt: self.publishedAt,
            bookmarked: self.bookmarked,
            documentId: documentId,
            bookmarkedAt: documentId != nil ? Date() : nil
        )
    }
    
    var hash: String {
        let seedString = "\(title)\(url)\(publishedAt)"
        let data = Data(seedString.utf8)
        let hashed = SHA256.hash(data: data)
        return hashed.compactMap { String(format: "%02x", $0)}.joined()
    }
}

struct ArticleSource: Decodable, Hashable {
    let name: String
}
