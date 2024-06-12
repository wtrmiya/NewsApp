//
//  HomeViewModel.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/11.
//

import Foundation

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
            if let error = error as? NetworkError {
                self.errorMessage = error.rawValue
            } else {
                self.errorMessage = "Sorry, something wrong. error: \(error.localizedDescription)"
            }
        }
    }
    
    func toggleBookmark(articleIndex: Int) {
        articles[articleIndex].toggleBookmark()
    }
}
