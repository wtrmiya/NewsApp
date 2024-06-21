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

    init(accountManager: AccountProtocol = AccountManager.shared,
         bookmarkManager: BookmarkManagerProtocol = BookmarkManager.shared,
         userDataStoreManager: UserDataStoreManagerProtocol = UserDataStoreManager.shared
    ) {
        self.accountManager = accountManager
        self.bookmarkManager = bookmarkManager
        self.userDataStoreManager = userDataStoreManager
    }
    
    @MainActor
    func populateBookmarkedArticles() async {
        do {
            guard let tempUser = accountManager.user else {
                return
            }
            
            let userDocumentId = try await userDataStoreManager.getUserDataStoreDocumentId(user: tempUser)
            let currentUser = UserAccount(
                uid: tempUser.uid,
                email: tempUser.email,
                displayName: tempUser.displayName,
                documentId: userDocumentId
            )

            let bookmarkedArticles = try await bookmarkManager.getBookmarks(user: currentUser)
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
            guard let tempUser = accountManager.user else {
                return
            }
            
            let userDocumentId = try await userDataStoreManager.getUserDataStoreDocumentId(user: tempUser)
            let currentUser = UserAccount(
                uid: tempUser.uid,
                email: tempUser.email,
                displayName: tempUser.displayName,
                documentId: userDocumentId
            )
            
            let bookmarksToDelete = indexSet.compactMap { articles[$0] }
            try await bookmarkManager.deleteBookmarks(articles: bookmarksToDelete, user: currentUser)
            let updatedBookmarkedArticles = try await bookmarkManager.getBookmarks(user: currentUser)
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
