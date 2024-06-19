//
//  HomeViewModel.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/11.
//

import Foundation

final class HomeViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var selectedCategory: ArticleCategory = .general
    
    @Published var errorMessage: String?
    
    let articleManager: ArticleManagerProtocol
    let bookmarkManager: BookmarkManagerProtocol
    let accountManager: AccountProtocol
    let userDataStoreManager: UserDataStoreManagerProtocol
    
    init(articleManager: ArticleManagerProtocol = ArticleManager.shared,
         bookmarkManager: BookmarkManagerProtocol = BookmarkManager.shared,
         accountManager: AccountProtocol = AccountManager.shared,
         userDataSoreManager: UserDataStoreManagerProtocol = UserDataStoreManager.shared
    ) {
        self.articleManager = articleManager
        self.bookmarkManager = bookmarkManager
        self.accountManager = accountManager
        self.userDataStoreManager = userDataSoreManager
    }
    
    var isSignedIn: Bool {
        accountManager.isSignedIn
    }
    
    @MainActor
    func populateDefaultArticles() async {
        await populateArticles(of: .general)
    }
    
    @MainActor
    func populateArticlesOfCurrentCategory() async {
        await populateArticles(of: self.selectedCategory)
    }
    
    @MainActor
    func populateArticles(of category: ArticleCategory) async {
        do {
            selectedCategory = category
            var downloadedArticles = try await articleManager.getArticlesByCategory(category: category)
            
            // ログインしていれば、ブックマーク状態を反映する
            if let tempUser = accountManager.user {
                let userDocumentId = try await userDataStoreManager.getUserDataStoreDocumentId(user: tempUser)
                let currentUser = UserAccount(
                    uid: tempUser.uid,
                    email: tempUser.email,
                    displayName: tempUser.displayName,
                    documentId: userDocumentId
                )
                let bookmarkedArticles = try await bookmarkManager.getBookmarks(user: currentUser)
                
                for bookmaredArticle in bookmarkedArticles {
                    // swiftlint:disable:next line_length
                    for (index, downloadedArticle) in downloadedArticles.enumerated() where bookmaredArticle.hash == downloadedArticle.hash {
                        // swiftlint:disable:previous line_length
                        downloadedArticles[index] = bookmaredArticle
                    }
                }
            }

            self.articles = downloadedArticles
        } catch {
            if let error = error as? NetworkError {
                self.errorMessage = error.rawValue
            } else {
                self.errorMessage = "Sorry, something wrong. error: \(error.localizedDescription)"
            }
        }
    }
    
    @MainActor
    func toggleBookmark(on articleToToggle: Article) async {
        let (article, index) = toggledArticleAndIndexOnArticles(articleToToggle: articleToToggle)
        
        guard let toggledArticle = article,
              let toggledArticleIndex = index
        else { return }
        
        guard let tempUser = accountManager.user else { return }
        
        do {
            let userDocumentId = try await userDataStoreManager.getUserDataStoreDocumentId(user: tempUser)
            let currentUser = UserAccount(
                uid: tempUser.uid,
                email: tempUser.email,
                displayName: tempUser.displayName,
                documentId: userDocumentId
            )
            self.articles[toggledArticleIndex] = toggledArticle
            
            if toggledArticle.bookmarked {
                guard let updatedArticle = try await bookmarkManager.addBookmark(
                    article: toggledArticle,
                    user: currentUser
                )
                else {
                    return
                }
                
                articles[toggledArticleIndex] = updatedArticle
            } else {
                guard let updatedArticle = try await bookmarkManager.deleteBookmark(
                    article: toggledArticle,
                    user: currentUser
                )
                else {
                    return
                }
                articles[toggledArticleIndex] = updatedArticle
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func toggledArticleAndIndexOnArticles(articleToToggle: Article) -> (Article?, Int?) {
        var toggledArticle: Article?
        var toggledArticleIndex: Int?
        for (index, article) in articles.enumerated() where article.id == articleToToggle.id {
            toggledArticle = article.bookmarkToggled
            toggledArticleIndex = index
            break
        }
        
        return (toggledArticle, toggledArticleIndex)
    }
}
