//
//  NewsAppUserDataStoreManagerIntegrationTest.swift
//  NewsAppIntegrationTests
//
//  Created by Wataru Miyakoshi on 2024/08/13.
//

import XCTest
@testable import NewsApp
import FirebaseFirestore
import FirebaseFirestoreSwift

final class NewsAppUserDataStoreManagerIntegrationTest: XCTestCase {
    func test_ユーザデータストアを作成する() async {
        let collectionRef = Firestore.firestore().collection("users")
        
        let dummyUserAccount = UserAccount(
            uid: UUID().uuidString,
            email: "testuser@example.com",
            displayName: "testuser"
        )
        
        let sut = UserDataStoreManager.shared
        
        do {
            try await sut.createUserDataStore(userAccount: dummyUserAccount)
        } catch {
            XCTFail("Error throwed: \(error.localizedDescription)")
            return
        }
        
        let userDocumentSnapshot: QueryDocumentSnapshot
        
        do {
            guard let tempSnapshot = try await collectionRef
                .whereField("uid", isEqualTo: dummyUserAccount.uid)
                .getDocuments()
                .documents
                .first
            else {
                return
            }
            userDocumentSnapshot = tempSnapshot
        } catch {
            XCTFail("Error throwed: \(error.localizedDescription)")
            return
        }
        
        guard let fetchedUserAccount = UserAccount.fromSnapshot(snapshot: userDocumentSnapshot)
        else {
            XCTFail("Failed in initializing")
            return
        }
        
        XCTAssertEqual(fetchedUserAccount.uid, dummyUserAccount.uid)
        XCTAssertEqual(fetchedUserAccount.displayName, dummyUserAccount.displayName)
        
        // tearDown
        // 全てのドキュメントを取得し
        // それぞれ削除する
        
        do {
            let documentsSnapshot = try await collectionRef
                .getDocuments()
            for document in documentsSnapshot.documents {
                try await document.reference.delete()
            }
            
        } catch {
            XCTFail("Throwed in deleting data")
            return
        }
    }

    func test_ユーザデータストアからデータを取得する() async {
        let collectionRef = Firestore.firestore().collection("users")
        
        let dummyUserAccount = UserAccount(
            uid: UUID().uuidString,
            email: "testuser@example.com",
            displayName: "testuser"
        )
        
        let sut = UserDataStoreManager.shared
        
        do {
            let _ = try await collectionRef.addDocument(data: [
                "uid": dummyUserAccount.uid,
                "displayName": dummyUserAccount.displayName
            ])
        } catch {
            XCTFail("Error throwed: \(error.localizedDescription)")
            return
        }
        
        let userDataStoreDocumentId: String
        do {
            userDataStoreDocumentId = try await sut.getUserDataStoreDocumentId(userAccount: dummyUserAccount)
        } catch {
            XCTFail("Error throwed: \(error.localizedDescription)")
            return
        }
        
        let docRef = collectionRef.document(userDataStoreDocumentId)
        
        let documentSnapshot: DocumentSnapshot
        do {
            documentSnapshot = try await docRef.getDocument()
        } catch {
            XCTFail("Error throwed: \(error.localizedDescription)")
            return
        }
        
        guard let fetchedUserAccount = UserAccount.fromSnapshot(snapshot: documentSnapshot)
        else {
            XCTFail("Failed in instantiating")
            return
        }
        
        XCTAssertEqual(fetchedUserAccount.uid, dummyUserAccount.uid)
        XCTAssertEqual(fetchedUserAccount.displayName, dummyUserAccount.displayName)
        
        // tearDown
        // 全てのドキュメントを取得し
        // それぞれ削除する
        
        do {
            let documentsSnapshot = try await collectionRef
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

fileprivate extension UserAccount {
    static func fromSnapshot(snapshot: DocumentSnapshot) -> UserAccount? {
        guard let dictionary = snapshot.data()
        else  {
            return nil
        }
        guard let uid = dictionary["uid"] as? String,
              let displayName = dictionary["displayName"] as? String
        else {
            return nil
        }

        return UserAccount(
            uid: uid,
            email: "test@example.com",
            displayName: displayName,
            userDataStoreDocumentId: snapshot.documentID
        )
    }

    static func fromSnapshot(snapshot: QueryDocumentSnapshot) -> UserAccount? {
        let dictionary = snapshot.data()
        guard let uid = dictionary["uid"] as? String,
              let displayName = dictionary["displayName"] as? String
        else {
            return nil
        }

        return UserAccount(
            uid: uid,
            email: "test@example.com",
            displayName: displayName,
            userDataStoreDocumentId: snapshot.documentID
        )
    }
}
