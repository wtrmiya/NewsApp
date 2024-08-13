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
    func test_ユーザデータストアを作成する() {
        let collectionRef = Firestore.firestore().collection("users")
        
        let dummyUserAccount = UserAccount(
            uid: UUID().uuidString,
            email: "testuser@example.com",
            displayName: "testuser"
        )
        
        let sut = UserDataStoreManager.shared
        
        let expectation = XCTestExpectation()
        Task {
            try await sut.createUserDataStore(userAccount: dummyUserAccount)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        let expectation2 = XCTestExpectation()
        Task {
            guard let userDocumentSnapshot = try await collectionRef
                .whereField("uid", isEqualTo: dummyUserAccount.uid)
                .getDocuments()
                .documents
                .first
            else {
                XCTFail("no collecton: users")
                return
            }
            
            expectation2.fulfill()
            
            guard let fetchedUserAccount = UserAccount.fromSnapshot(snapshot: userDocumentSnapshot)
            else {
                XCTFail("Failed in initializing")
                return
            }
            
            XCTAssertEqual(fetchedUserAccount.uid, dummyUserAccount.uid)
            XCTAssertEqual(fetchedUserAccount.displayName, dummyUserAccount.displayName)
        }
        
        wait(for: [expectation2], timeout: 5.0)
        
        // tearDown
        // 全てのドキュメントを取得し
        // それぞれ削除する
        
        let expectationTearDown = XCTestExpectation()
        Task {
            do {
                let documentsSnapshot = try await collectionRef
                    .getDocuments()
                for document in documentsSnapshot.documents {
                    try await document.reference.delete()
                }
                
                expectationTearDown.fulfill()
            } catch {
                XCTFail("Throwed in deleting data")
                return
            }
        }
        
        wait(for: [expectationTearDown], timeout: 5.0)
    }
    
    func test_ユーザデータストアからデータを取得する() {
        let collectionRef = Firestore.firestore().collection("users")
        
        let dummyUserAccount = UserAccount(
            uid: UUID().uuidString,
            email: "testuser@example.com",
            displayName: "testuser"
        )
        
        let sut = UserDataStoreManager.shared
        
        let expectation = XCTestExpectation()
        Task {
            collectionRef.addDocument(data: [
                "uid": dummyUserAccount.uid,
                "displayName": dummyUserAccount.displayName
            ])
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        let expectation2 = XCTestExpectation()
        Task {
            let userDataStoreDocumentId = try await sut.getUserDataStoreDocumentId(userAccount: dummyUserAccount)
            
            expectation2.fulfill()
            
            let docRef = collectionRef.document(userDataStoreDocumentId)
            let documentSnapshot = try await docRef.getDocument()
            
            guard let fetchedUserAccount = UserAccount.fromSnapshot(snapshot: documentSnapshot)
            else {
                XCTFail("Failed in instantiating")
                return
            }
            
            XCTAssertEqual(fetchedUserAccount.uid, dummyUserAccount.uid)
            XCTAssertEqual(fetchedUserAccount.displayName, dummyUserAccount.displayName)
        }
        
        wait(for: [expectation2], timeout: 5.0)
        
        // tearDown
        // 全てのドキュメントを取得し
        // それぞれ削除する
        
        let expectationTearDown = XCTestExpectation()
        Task {
            do {
                let documentsSnapshot = try await collectionRef
                    .getDocuments()
                for document in documentsSnapshot.documents {
                    try await document.reference.delete()
                }
                
                expectationTearDown.fulfill()
            } catch {
                XCTFail("Throwed in deleting data")
                return
            }
        }
        
        wait(for: [expectationTearDown], timeout: 5.0)
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
