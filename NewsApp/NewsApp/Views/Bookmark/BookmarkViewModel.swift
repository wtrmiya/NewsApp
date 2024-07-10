//
//  BookmarkViewModel.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/09.
//

import Foundation

final class BookmarkViewModel: ObservableObject {
    @Published var articles: [Article] = []

    @Published var errorMessage: String?
    
    let accountManager: AccountProtocol
    let bookmarkManager: BookmarkManagerProtocol
    let userDataStoreManager: UserDataStoreManagerProtocol

    init(accountManager: AccountProtocol,
         bookmarkManager: BookmarkManagerProtocol,
         userDataStoreManager: UserDataStoreManagerProtocol
    ) {
        self.accountManager = accountManager
        self.bookmarkManager = bookmarkManager
        self.userDataStoreManager = userDataStoreManager
    }
    
    @MainActor
    func populateBookmarkedArticles() async {
        do {
            guard let tempUserAccount = accountManager.userAccount else {
                return
            }
            
            let userDocumentId = try await userDataStoreManager.getUserDataStoreDocumentId(userAccount: tempUserAccount)
            let currentUserAccount = UserAccount(
                uid: tempUserAccount.uid,
                email: tempUserAccount.email,
                displayName: tempUserAccount.displayName,
                userDataStoreDocumentId: userDocumentId
            )

            let bookmarkedArticles = try await bookmarkManager.getBookmarks(userAccount: currentUserAccount)
            self.articles = bookmarkedArticles
        } catch {
            if let error = error as? NetworkError {
                self.errorMessage = error.rawValue
            } else {
                self.errorMessage = "Sorry, something wrong. error: \(error.localizedDescription)"
            }
        }
    }
    
    @MainActor
    func deleteBookmarks(indexSet: IndexSet) async {
        do {
            guard let tempUserAccount = accountManager.userAccount else {
                return
            }
            
            let userDocumentId = try await userDataStoreManager.getUserDataStoreDocumentId(userAccount: tempUserAccount)
            let currentUserAccount = UserAccount(
                uid: tempUserAccount.uid,
                email: tempUserAccount.email,
                displayName: tempUserAccount.displayName,
                userDataStoreDocumentId: userDocumentId
            )
            
            let bookmarksToDelete = indexSet.compactMap { articles[$0] }
            try await bookmarkManager.deleteBookmarks(articles: bookmarksToDelete, userAccount: currentUserAccount)
            let updatedBookmarkedArticles = try await bookmarkManager.getBookmarks(userAccount: currentUserAccount)
            self.articles = updatedBookmarkedArticles
        } catch {
            if let error = error as? NetworkError {
                self.errorMessage = error.rawValue
            } else {
                self.errorMessage = "Sorry, something wrong. error: \(error.localizedDescription)"
            }
        }
    }
}
