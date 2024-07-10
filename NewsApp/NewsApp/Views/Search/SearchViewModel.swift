//
//  SearchViewModel.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/19.
//

import Foundation

final class SearchViewModel: ObservableObject {
    @Published var searchResultArticles: [Article] = []
    @Published var searchResultWord: String = ""

    @Published var errorMessage: String?
    
    private let articleManager: ArticleManagerProtocol
    private let accountManager: AccountProtocol
    private let userDataStoreManager: UserDataStoreManagerProtocol
    private let bookmarkManager: BookmarkManagerProtocol

    init(
        articleManager: ArticleManagerProtocol,
        accountManager: AccountProtocol,
        userDataStoreManager: UserDataStoreManagerProtocol,
        bookmarkManager: BookmarkManagerProtocol
    ) {
        self.articleManager = articleManager
        self.accountManager = accountManager
        self.userDataStoreManager = userDataStoreManager
        self.bookmarkManager = bookmarkManager
    }
    
    var isSignedIn: Bool {
        accountManager.isSignedIn
    }
    
    @MainActor
    func fetchArticle(searchText: String) async {
        do {
            var downloadedArticles = try await articleManager.getArticlesBySearchText(text: searchText)
            
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

            self.searchResultArticles = downloadedArticles
            self.searchResultWord = searchText
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
        
        guard let tempUserAccount = accountManager.userAccount else { return }
        
        do {
            let userDocumentId = try await userDataStoreManager.getUserDataStoreDocumentId(userAccount: tempUserAccount)
            let currentUserAccount = UserAccount(
                uid: tempUserAccount.uid,
                email: tempUserAccount.email,
                displayName: tempUserAccount.displayName,
                userDataStoreDocumentId: userDocumentId
            )
            self.searchResultArticles[toggledArticleIndex] = toggledArticle
            
            if toggledArticle.bookmarked {
                guard let updatedArticle = try await bookmarkManager.addBookmark(
                    article: toggledArticle,
                    userAccount: currentUserAccount
                )
                else {
                    return
                }
                
                searchResultArticles[toggledArticleIndex] = updatedArticle
            } else {
                guard let updatedArticle = try await bookmarkManager.deleteBookmark(
                    article: toggledArticle,
                    userAccount: currentUserAccount
                )
                else {
                    return
                }
                searchResultArticles[toggledArticleIndex] = updatedArticle
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func toggledArticleAndIndexOnArticles(articleToToggle: Article) -> (Article?, Int?) {
        var toggledArticle: Article?
        var toggledArticleIndex: Int?
        for (index, article) in searchResultArticles.enumerated() where article.id == articleToToggle.id {
            toggledArticle = article.bookmarkToggled
            toggledArticleIndex = index
            break
        }
        
        return (toggledArticle, toggledArticleIndex)
    }
}
