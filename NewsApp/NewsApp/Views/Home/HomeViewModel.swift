//
//  HomeViewModel.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/11.
//

import Foundation

enum HomeViewModelError: Error {
    case noArticleWithSpecifiedId
    case noUserAccount
    case noUpdatedArticle
}

final class HomeViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var selectedCategory: ArticleCategory = .general

    @Published var errorMessage: String?
    
    let articleManager: ArticleManagerProtocol
    let bookmarkManager: BookmarkManagerProtocol
    let accountManager: AccountProtocol
    let userDataStoreManager: UserDataStoreManagerProtocol
    
    init(articleManager: ArticleManagerProtocol,
         bookmarkManager: BookmarkManagerProtocol,
         accountManager: AccountProtocol,
         userDataSoreManager: UserDataStoreManagerProtocol
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
            if let tempUserAccount = accountManager.userAccount {
                let userDocumentId = try await userDataStoreManager.getUserDataStoreDocumentId(
                    userAccount: tempUserAccount
                )
                let currentUserAccount = UserAccount(
                    uid: tempUserAccount.uid,
                    email: tempUserAccount.email,
                    displayName: tempUserAccount.displayName,
                    userDataStoreDocumentId: userDocumentId
                )
                let bookmarkedArticles = try await bookmarkManager.getBookmarks(userAccount: currentUserAccount)
                
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
            self.errorMessage = "error: \(error.localizedDescription)"
        }
    }
    
    @MainActor
    func toggleBookmark(on articleToToggle: Article) async {
        do {
            let (article, index) = toggledArticleAndIndexOnArticles(articleToToggle: articleToToggle)
            
            guard let toggledArticle = article,
                  let toggledArticleIndex = index
            else {
                throw HomeViewModelError.noArticleWithSpecifiedId
            }
            
            guard let tempUserAccount = accountManager.userAccount
            else {
                throw HomeViewModelError.noUserAccount
            }
        
            let userDocumentId = try await userDataStoreManager.getUserDataStoreDocumentId(userAccount: tempUserAccount)
            let currentUserAccount = UserAccount(
                uid: tempUserAccount.uid,
                email: tempUserAccount.email,
                displayName: tempUserAccount.displayName,
                userDataStoreDocumentId: userDocumentId
            )
            self.articles[toggledArticleIndex] = toggledArticle
            
            if toggledArticle.bookmarked {
                guard let updatedArticle = try await bookmarkManager.addBookmark(
                    article: toggledArticle,
                    userAccount: currentUserAccount
                )
                else {
                    throw HomeViewModelError.noUpdatedArticle
                }
                
                articles[toggledArticleIndex] = updatedArticle
            } else {
                guard let updatedArticle = try await bookmarkManager.deleteBookmark(
                    article: toggledArticle,
                    userAccount: currentUserAccount
                )
                else {
                    throw HomeViewModelError.noUpdatedArticle
                }
                articles[toggledArticleIndex] = updatedArticle
            }
        } catch {
            errorMessage = "error: \(error.localizedDescription)"
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
