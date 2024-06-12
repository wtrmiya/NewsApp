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
    let bookmarkManager = BookmarkManager.shared
    let accountManager = AccountManager.shared
    
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
    
    @MainActor
    func toggleBookmark(articleIndex: Int) async {
        articles[articleIndex].toggleBookmark()
        let toggledArticle = articles[articleIndex]
        guard let currentUser = accountManager.user else {
            return
        }
        
        do {
            if toggledArticle.bookmarked {
                guard let updatedArticle = try await bookmarkManager.addBookmark(
                    article: toggledArticle,
                    uid: currentUser.uid
                )
                else {
                    return
                }
                
                articles[articleIndex] = updatedArticle
            } else {
                guard let updatedArticle = try await bookmarkManager.removeBookmark(
                    article: toggledArticle,
                    uid: currentUser.uid
                )
                else {
                    return
                }
                articles[articleIndex] = updatedArticle
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
