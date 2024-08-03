//
//  SearchViewModel.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/19.
//

import Foundation

enum SearchViewModelError: Error {
    case noArticleWithSpecifiedId
    case noUserAccount
    case noUpdatedArticle
}

final class SearchViewModel: ObservableObject {
    @Published var searchResultArticles: [Article] = []
    @Published var searchResultWord: String = ""

    @Published var errorMessage: String?
    
    private let articleManager: ArticleManagerProtocol
    private let accountManager: AccountManagerProtocol
    private let userDataStoreManager: UserDataStoreManagerProtocol
    private let bookmarkManager: BookmarkManagerProtocol

    init(
        articleManager: ArticleManagerProtocol,
        accountManager: AccountManagerProtocol,
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
                throw SearchViewModelError.noArticleWithSpecifiedId
            }
            
            guard let tempUserAccount = accountManager.userAccount
            else {
                throw SearchViewModelError.noUserAccount
            }
            
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
                    throw SearchViewModelError.noUpdatedArticle
                }
                
                searchResultArticles[toggledArticleIndex] = updatedArticle
            } else {
                guard let updatedArticle = try await bookmarkManager.deleteBookmark(
                    article: toggledArticle,
                    userAccount: currentUserAccount
                )
                else {
                    throw SearchViewModelError.noUpdatedArticle
                }
                searchResultArticles[toggledArticleIndex] = updatedArticle
            }
        } catch {
            errorMessage = "error: \(error.localizedDescription)"
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
