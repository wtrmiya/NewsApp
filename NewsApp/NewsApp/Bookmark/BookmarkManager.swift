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
    
    private let firestoreDB = Firestore.firestore()
}

private extension BookmarkManager {
    func getBookmarksCollectionReference(userDocumentId: String) -> CollectionReference {
        let userDocRef = firestoreDB.collection("users").document(userDocumentId)
        let bookmarksCollectionRef = userDocRef.collection("bookmarks")
        return bookmarksCollectionRef
    }
}

extension BookmarkManager: BookmarkManagerProtocol {
    func addBookmark(article: Article, user: UserAccount) async throws -> Article? {
        guard let userDocumentId = user.documentId else {
            return nil
        }
        guard article.bookmarked else {
            return nil
        }
        
        let bookmarksCollectionRef = getBookmarksCollectionReference(userDocumentId: userDocumentId)
        let docRef = try await bookmarksCollectionRef.addDocument(data: article.toDictionary())
        let updatedArticle = article.updateBookmarkedData(documentId: docRef.documentID)
        return updatedArticle
    }
    
    func deleteBookmark(article: Article, user: UserAccount) async throws -> Article? {
        guard let userDocumentId = user.documentId else { return nil }
        guard !article.bookmarked else { return nil }
        
        guard let bookmarkDocumentId = article.documentId
        else { return nil }
        
        let bookmarksCollectionRef = getBookmarksCollectionReference(userDocumentId: userDocumentId)

        let docRef = bookmarksCollectionRef.document(bookmarkDocumentId)
        try await docRef.delete()
        let updatedArticle = article.updateBookmarkedData(documentId: nil)
        return updatedArticle
    }
    
    func deleteBookmarks(articles: [Article], user: UserAccount) async throws {
        guard let userDocumentId = user.documentId else { return }
        
        let bookmarksCollectionRef = getBookmarksCollectionReference(userDocumentId: userDocumentId)

        let batch = firestoreDB.batch()
        for articleToDelete in articles {
            guard let docID = articleToDelete.documentId
            else { continue }
            let ref = bookmarksCollectionRef.document(docID)
            batch.deleteDocument(ref)
        }
        try await batch.commit()
    }
    
    func getBookmarks(user: UserAccount) async throws -> [Article] {
        guard let userDocumentId = user.documentId else { return [] }
        
        let bookmarksCollectionRef = getBookmarksCollectionReference(userDocumentId: userDocumentId)

        let snapshot = try await bookmarksCollectionRef.getDocuments()
        
        let bookmarks = snapshot.documents.compactMap { snapshot in
            Article.fromSnapshot(snapshot: snapshot)
        }
        
        return bookmarks
    }
}
