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
    let bookmarkManager = BookmarkManager.shared

    init(accountManager: AccountProtocol = AccountManager.shared) {
        self.accountManager = accountManager
    }
    
    var isSignedIn: Bool {
        accountManager.isSignedIn
    }
    
    @MainActor
    func populateBookmarkedArticles() async {
        do {
            guard let currentUser = accountManager.user else {
                return
            }
            let bookmarkedArticles = try await bookmarkManager.getBookmarks(uid: currentUser.uid)
            self.articles = bookmarkedArticles
        } catch {
            if let error = error as? NetworkError {
                self.errorMessage = error.rawValue
            } else {
                self.errorMessage = "Sorry, something wrong. error: \(error.localizedDescription)"
            }
        }
    }
}
