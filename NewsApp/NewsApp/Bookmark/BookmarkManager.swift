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

extension BookmarkManager: BookmarkManagerProtocol {
    func addBookmark(article: Article, user: UserAccount) async throws -> Article? {
        guard let userDocumentId = user.documentId else {
            return nil
        }
        guard article.bookmarked else {
            return nil
        }
        
        let firestoreDB = Firestore.firestore()
        
        let docRef = try await firestoreDB.collection("users").document(userDocumentId)
            .collection("bookmarks").addDocument(data: article.toDictionary())
        let updatedArticle = article.updateBookmarkedData(documentId: docRef.documentID)
        return updatedArticle
    }
    
    func deleteBookmark(article: Article, user: UserAccount) async throws -> Article? {
        guard let userDocumentId = user.documentId else { return nil }
        guard !article.bookmarked else { return nil }
        
        let firestoreDB = Firestore.firestore()
        guard let bookmarkDocumentId = article.documentId
        else { return nil }
        
        let docRef = firestoreDB.collection("users").document(userDocumentId)
            .collection("bookmarks").document(bookmarkDocumentId)
        try await docRef.delete()
        let updatedArticle = article.updateBookmarkedData(documentId: nil)
        return updatedArticle
    }
    
    func deleteBookmarks(articles: [Article], uid: String) async throws {
        let firestoreDB = Firestore.firestore()
        guard let userDocumentID = try await firestoreDB.collection("users")
            .whereField("uid", isEqualTo: uid)
            .getDocuments()
            .documents.first?.documentID
        else { return }
        
        let collectionRef = firestoreDB.collection("users").document(userDocumentID)
            .collection("bookmarks")
        
        let batch = firestoreDB.batch()
        for articleToDelete in articles {
            guard let docID = articleToDelete.documentId
            else { continue }
            let ref = collectionRef.document(docID)
            batch.deleteDocument(ref)
        }
        try await batch.commit()
    }
    
    func getBookmarks(uid: String) async throws -> [Article] {
        let firestoreDB = Firestore.firestore()
        guard let userDocumentID = try await firestoreDB.collection("users")
            .whereField("uid", isEqualTo: uid)
            .getDocuments()
            .documents.first?.documentID
        else { return [] }
        
        let snapshot = try await firestoreDB.collection("users").document(userDocumentID)
            .collection("bookmarks").getDocuments()
        
        let bookmarks = snapshot.documents.compactMap { snapshot in
            Article.fromSnapshot(snapshot: snapshot)
        }
        
        return bookmarks
    }
}
