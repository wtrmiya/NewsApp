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
    func addBookmark(article: Article, uid: String) async throws -> Article? {
        guard article.bookmarked else { return nil }
        
        let firestoreDB = Firestore.firestore()
        guard let userDocumentID = try await firestoreDB.collection("users")
            .whereField("uid", isEqualTo: uid)
            .getDocuments()
            .documents.first?.documentID
        else {
            return nil
        }
        
        let docRef = try await firestoreDB.collection("users").document(userDocumentID)
            .collection("bookmarks").addDocument(data: article.toDictionary())
        let updatedArticle = article.updateBookmarkedData(documentId: docRef.documentID)
        return updatedArticle
    }
    
    func removeBookmark(article: Article, uid: String) {
        guard !article.bookmarked else { return }
    }
}
