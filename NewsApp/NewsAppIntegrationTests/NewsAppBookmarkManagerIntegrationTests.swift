//
//  NewsAppBookmarkManagerIntegrationTests.swift
//  NewsAppIntegrationTests
//
//  Created by Wataru Miyakoshi on 2024/08/15.
//

import XCTest
@testable import NewsApp
import FirebaseFirestore
import FirebaseFirestoreSwift

final class NewsAppBookmarkManagerIntegrationTests: XCTestCase {
    func test_ブックマークを作成する() async {
        let usersCollectionRef = Firestore.firestore().collection("users")
        
        var dummyUserAccount = UserAccount(
            uid: UUID().uuidString,
            email: "testuser@example.com",
            displayName: "testuser"
        )
        
        var dummyArticle = Article(
            source: ArticleSource(name: "Example.com"),
            author: nil,
            title: "サンプル記事 タイトル 先発出場で二塁打もチーム敗れる | Example | サンプル記事 - example.com",
            description: "サンプル記事、ドジャースの選手は9日、ヤンキースとの3連戦の最終戦に先発出場し、ツーベースヒット1本を打ちましたが、…",
            url: "https://www.example.com/news/html/20240610/k10014475991000.html",
            urlToImage: "https://www.example.com/news/html/20240610/sample_image_01.jpg",
            publishedAt: "2024-06-10T04:12:02Z",
            bookmarked: true,
            documentId: nil,
            bookmarkedAt: nil
        )

        let sut = BookmarkManager.shared
        let userDataStoreDocRef: DocumentReference
        let userDataStoreDocumentId: String
        do {
            userDataStoreDocRef = try await usersCollectionRef.addDocument(data: [
                "uid": dummyUserAccount.uid,
                "displayName": dummyUserAccount.displayName
            ])
            userDataStoreDocumentId = userDataStoreDocRef.documentID
            dummyUserAccount.setUserDataStoreDocumentId(userDataStoreDocumentId: userDataStoreDocumentId)
            
        } catch {
            XCTFail("Error throwed")
            return
        }
        
        do {
            // Test
            let _ = try await sut.addBookmark(
                article: dummyArticle,
                userAccount: dummyUserAccount
            )
        } catch {
            XCTFail("Error throwed")
            return
        }

        // Check
        let fetchedUserDataStoreDocRef = usersCollectionRef.document(userDataStoreDocRef.documentID)
        let bookmarksCollectionRef = fetchedUserDataStoreDocRef.collection("bookmarks")
        do {
            guard let queryDocumentSnapshot = try await bookmarksCollectionRef.getDocuments().documents.first
            else {
                return
            }
            
            guard let fetchedArticle = Article.fromSnapshot(snapshot: queryDocumentSnapshot)
            else {
                return
            }
            
            XCTAssertEqual(fetchedArticle.title, dummyArticle.title)
        } catch {
            XCTFail("Error throwed")
            return
        }
        
        // tearDown
        do {
            // bookmarks
            let bookmarksDocumentSnapshot = try await bookmarksCollectionRef.getDocuments()
            for bookmarksDocument in bookmarksDocumentSnapshot.documents {
                try await bookmarksDocument.reference.delete()
            }
            
            // users
            let documentsSnapshot = try await usersCollectionRef
                .getDocuments()
            for document in documentsSnapshot.documents {
                try await document.reference.delete()
            }
        } catch {
            XCTFail("Throwed in deleting data")
            return
        }
    }
    
    func test_ブックマークを取得する() async {
        let usersCollectionRef = Firestore.firestore().collection("users")
        
        var dummyUserAccount = UserAccount(
            uid: UUID().uuidString,
            email: "testuser@example.com",
            displayName: "testuser"
        )
        
        var dummyArticle = Article(
            source: ArticleSource(name: "Example.com"),
            author: nil,
            title: "サンプル記事 タイトル 先発出場で二塁打もチーム敗れる | Example | サンプル記事 - example.com",
            description: "サンプル記事、ドジャースの選手は9日、ヤンキースとの3連戦の最終戦に先発出場し、ツーベースヒット1本を打ちましたが、…",
            url: "https://www.example.com/news/html/20240610/k10014475991000.html",
            urlToImage: "https://www.example.com/news/html/20240610/sample_image_01.jpg",
            publishedAt: "2024-06-10T04:12:02Z",
            bookmarked: true,
            documentId: nil,
            bookmarkedAt: nil
        )

        let sut = BookmarkManager.shared
        let userDataStoreDocRef: DocumentReference
        let userDataStoreDocumentId: String
        do {
            userDataStoreDocRef = try await usersCollectionRef.addDocument(data: [
                "uid": dummyUserAccount.uid,
                "displayName": dummyUserAccount.displayName
            ])
            userDataStoreDocumentId = userDataStoreDocRef.documentID
            dummyUserAccount.setUserDataStoreDocumentId(userDataStoreDocumentId: userDataStoreDocumentId)
        } catch {
            XCTFail("Error throwed")
            return
        }
        
        let bookmarksCollectionRef = userDataStoreDocRef.collection("bookmarks")
        do {
            try await bookmarksCollectionRef.addDocument(data: dummyArticle.toDictionary())
        } catch {
            XCTFail("Error throwed")
            return
        }
        
        let fetchedArticles: [Article]
        do {
            // Test
            fetchedArticles = try await sut.getBookmarks(userAccount: dummyUserAccount)
        } catch {
            XCTFail("Error throwed")
            return
        }

        // Check
        XCTAssertEqual(fetchedArticles.count, 1)
        XCTAssertEqual(fetchedArticles[0].title, dummyArticle.title)
        
        // tearDown
        do {
            // bookmarks
            let bookmarksDocumentSnapshot = try await bookmarksCollectionRef.getDocuments()
            for bookmarksDocument in bookmarksDocumentSnapshot.documents {
                try await bookmarksDocument.reference.delete()
            }
            
            // users
            let documentsSnapshot = try await usersCollectionRef
                .getDocuments()
            for document in documentsSnapshot.documents {
                try await document.reference.delete()
            }
        } catch {
            XCTFail("Throwed in deleting data")
            return
        }
    }
    
    func test_指定したブックマークを削除する() async {
        let usersCollectionRef = Firestore.firestore().collection("users")
        
        var dummyUserAccount = UserAccount(
            uid: UUID().uuidString,
            email: "testuser@example.com",
            displayName: "testuser"
        )
        
        var dummyArticle = Article(
            source: ArticleSource(name: "Example.com"),
            author: nil,
            title: "サンプル記事 タイトル 先発出場で二塁打もチーム敗れる | Example | サンプル記事 - example.com",
            description: "サンプル記事、ドジャースの選手は9日、ヤンキースとの3連戦の最終戦に先発出場し、ツーベースヒット1本を打ちましたが、…",
            url: "https://www.example.com/news/html/20240610/k10014475991000.html",
            urlToImage: "https://www.example.com/news/html/20240610/sample_image_01.jpg",
            publishedAt: "2024-06-10T04:12:02Z",
            bookmarked: false,
            documentId: nil,
            bookmarkedAt: nil
        )

        let sut = BookmarkManager.shared
        let userDataStoreDocRef: DocumentReference
        let userDataStoreDocumentId: String
        do {
            userDataStoreDocRef = try await usersCollectionRef.addDocument(data: [
                "uid": dummyUserAccount.uid,
                "displayName": dummyUserAccount.displayName
            ])
            userDataStoreDocumentId = userDataStoreDocRef.documentID
            dummyUserAccount.setUserDataStoreDocumentId(userDataStoreDocumentId: userDataStoreDocumentId)
        } catch {
            XCTFail("Error throwed")
            return
        }
        
        let bookmarksCollectionRef = userDataStoreDocRef.collection("bookmarks")
        do {
            let bookmarkDocRef = try await bookmarksCollectionRef.addDocument(data: dummyArticle.toDictionary())
            dummyArticle.documentId = bookmarkDocRef.documentID
        } catch {
            XCTFail("Error throwed")
            return
        }
        
        let unbookmarkedArticles: Article
        do {
            // Test
            guard let resultArticle = try await sut.deleteBookmark(
                article: dummyArticle,
                userAccount: dummyUserAccount
            ) else {
                XCTFail("Should not be nil")
                return
            }
            
            unbookmarkedArticles = resultArticle
        } catch {
            XCTFail("Error throwed")
            return
        }

        // Check
        XCTAssertEqual(unbookmarkedArticles.title, dummyArticle.title)
        XCTAssertFalse(unbookmarkedArticles.bookmarked)

        // tearDown
        do {
            // bookmarks
            let bookmarksDocumentSnapshot = try await bookmarksCollectionRef.getDocuments()
            for bookmarksDocument in bookmarksDocumentSnapshot.documents {
                try await bookmarksDocument.reference.delete()
            }
            
            // users
            let documentsSnapshot = try await usersCollectionRef
                .getDocuments()
            for document in documentsSnapshot.documents {
                try await document.reference.delete()
            }
        } catch {
            XCTFail("Throwed in deleting data")
            return
        }
    }
    
    func test_指定した複数のブックマークを削除する() async {
        let usersCollectionRef = Firestore.firestore().collection("users")
        
        var dummyUserAccount = UserAccount(
            uid: UUID().uuidString,
            email: "testuser@example.com",
            displayName: "testuser"
        )
        
        var dummyArticle = Article(
            source: ArticleSource(name: "Example.com"),
            author: nil,
            title: "サンプル記事 タイトル 先発出場で二塁打もチーム敗れる | Example | サンプル記事 - example.com",
            description: "サンプル記事、ドジャースの選手は9日、ヤンキースとの3連戦の最終戦に先発出場し、ツーベースヒット1本を打ちましたが、…",
            url: "https://www.example.com/news/html/20240610/k10014475991000.html",
            urlToImage: "https://www.example.com/news/html/20240610/sample_image_01.jpg",
            publishedAt: "2024-06-10T04:12:02Z",
            bookmarked: false,
            documentId: nil,
            bookmarkedAt: nil
        )

        let sut = BookmarkManager.shared
        let userDataStoreDocRef: DocumentReference
        let userDataStoreDocumentId: String
        do {
            userDataStoreDocRef = try await usersCollectionRef.addDocument(data: [
                "uid": dummyUserAccount.uid,
                "displayName": dummyUserAccount.displayName
            ])
            userDataStoreDocumentId = userDataStoreDocRef.documentID
            dummyUserAccount.setUserDataStoreDocumentId(userDataStoreDocumentId: userDataStoreDocumentId)
        } catch {
            XCTFail("Error throwed")
            return
        }
        
        let bookmarksCollectionRef = userDataStoreDocRef.collection("bookmarks")
        do {
            let bookmarkDocRef = try await bookmarksCollectionRef.addDocument(data: dummyArticle.toDictionary())
            dummyArticle.documentId = bookmarkDocRef.documentID
        } catch {
            XCTFail("Error throwed")
            return
        }
        
        do {
            // Test
            try await sut.deleteBookmarks(
                articles: [dummyArticle],
                userAccount: dummyUserAccount
            )
        } catch {
            XCTFail("Error throwed")
            return
        }

        // Check
        let fetchedUserDataStoreDocRef = usersCollectionRef.document(userDataStoreDocRef.documentID)
        do {
            let queryDocumentSnapshotArray = try await bookmarksCollectionRef.getDocuments().documents
            
            XCTAssertEqual(queryDocumentSnapshotArray.count, 0)
        } catch {
            XCTFail("Error throwed")
            return
        }

        // tearDown
        do {
            // bookmarks
            let bookmarksDocumentSnapshot = try await bookmarksCollectionRef.getDocuments()
            for bookmarksDocument in bookmarksDocumentSnapshot.documents {
                try await bookmarksDocument.reference.delete()
            }
            
            // users
            let documentsSnapshot = try await usersCollectionRef
                .getDocuments()
            for document in documentsSnapshot.documents {
                try await document.reference.delete()
            }
        } catch {
            XCTFail("Throwed in deleting data")
            return
        }
    }
}
