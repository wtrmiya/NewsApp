//
//  BookmarkManager.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/12.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

enum BookmarkManagerError: Error {
    case noUserDataStoreDocumentId
    case notBookmarked
    case bookmarked
    case rejectedWritingDocument
    case noArticleDocumentId
    case failedDeleteDocument
    case failedInCommittingDeletion
    case failedFetchingBookmarkDocuments
}

final class BookmarkManager {
    static let shared = BookmarkManager()
    private init() {}
    
    private let firestoreDB = Firestore.firestore()
}

private extension BookmarkManager {
    func getBookmarksCollectionReference(userDataStoreDocumentId: String) -> CollectionReference {
        let userDocRef = firestoreDB.collection("users").document(userDataStoreDocumentId)
        let bookmarksCollectionRef = userDocRef.collection("bookmarks")
        return bookmarksCollectionRef
    }
}

extension BookmarkManager: BookmarkManagerProtocol {
    func addBookmark(article: Article, userAccount: UserAccount) async throws -> Article? {
        guard let userDataStoreDocumentId = userAccount.userDataStoreDocumentId
        else {
            throw BookmarkManagerError.noUserDataStoreDocumentId
        }
        guard article.bookmarked
        else {
            throw BookmarkManagerError.notBookmarked
        }
        
        let bookmarksCollectionRef = getBookmarksCollectionReference(userDataStoreDocumentId: userDataStoreDocumentId)
        do {
            let docRef = try await bookmarksCollectionRef.addDocument(data: article.toDictionary())
            let updatedArticle = article.updateBookmarkedData(documentId: docRef.documentID)
            return updatedArticle
        } catch {
            print(error)
            throw BookmarkManagerError.rejectedWritingDocument
        }
    }
    
    func deleteBookmark(article: Article, userAccount: UserAccount) async throws -> Article? {
        guard let userDataStoreDocumentId = userAccount.userDataStoreDocumentId
        else {
            throw BookmarkManagerError.noUserDataStoreDocumentId
        }
        guard !article.bookmarked
        else {
            throw BookmarkManagerError.bookmarked
        }
        
        guard let bookmarkDocumentId = article.documentId
        else {
            throw BookmarkManagerError.noArticleDocumentId
        }
        
        let bookmarksCollectionRef = getBookmarksCollectionReference(userDataStoreDocumentId: userDataStoreDocumentId)

        do {
            let docRef = bookmarksCollectionRef.document(bookmarkDocumentId)
            try await docRef.delete()
            let updatedArticle = article.updateBookmarkedData(documentId: nil)
            return updatedArticle
        } catch {
            print(error)
            throw BookmarkManagerError.failedDeleteDocument
        }
    }
    
    func deleteBookmarks(articles: [Article], userAccount: UserAccount) async throws {
        guard let userDataStoreDocumentId = userAccount.userDataStoreDocumentId
        else {
            throw BookmarkManagerError.noUserDataStoreDocumentId
        }
        
        let bookmarksCollectionRef = getBookmarksCollectionReference(userDataStoreDocumentId: userDataStoreDocumentId)

        let batch = firestoreDB.batch()
        for articleToDelete in articles {
            guard let docID = articleToDelete.documentId
            else { continue }
            let ref = bookmarksCollectionRef.document(docID)
            batch.deleteDocument(ref)
        }
        
        do {
            try await batch.commit()
        } catch {
            print(error)
            throw BookmarkManagerError.failedInCommittingDeletion
        }
    }
    
    func getBookmarks(userAccount: UserAccount) async throws -> [Article] {
        guard let userDocumentId = userAccount.userDataStoreDocumentId
        else {
            throw BookmarkManagerError.noUserDataStoreDocumentId
        }
        
        let bookmarksCollectionRef = getBookmarksCollectionReference(userDataStoreDocumentId: userDocumentId)

        do {
            let snapshot = try await bookmarksCollectionRef.getDocuments()
            
            let bookmarks = snapshot.documents.compactMap { snapshot in
                Article.fromSnapshot(snapshot: snapshot)
            }
            
            return bookmarks
        } catch {
            print(error)
            throw BookmarkManagerError.failedFetchingBookmarkDocuments
        }
    }
}
