//
//  BookmarkManager.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/12.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class BookmarkManager {
    static let shared = BookmarkManager()
    private init() {}
}

extension BookmarkManager {
    func addBookmark(article: Article, uid: String) {
        guard article.bookmarked else { return }
        
        let firestoreDB = Firestore.firestore()
    }
    
    func removeBookmark(article: Article, uid: String) {
        guard !article.bookmarked else { return }
    }
}
