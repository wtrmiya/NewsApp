//
//  NewsAppUserSettingsManagerIntegrationTest.swift
//  NewsAppIntegrationTests
//
//  Created by Wataru Miyakoshi on 2024/08/13.
//

import XCTest
@testable import NewsApp
import FirebaseFirestore
import FirebaseFirestoreSwift

final class NewsAppUserSettingsManagerIntegrationTest: XCTestCase {
    func test_デフォルトのユーザ設定を作成する() async {
        let collectionRef = Firestore.firestore().collection("users")
        
        var dummyUserAccount = UserAccount(
            uid: UUID().uuidString,
            email: "testuser@example.com",
            displayName: "testuser"
        )
        
        let sut = UserSettingsManager.shared
        let userAccountDocRef: DocumentReference
        
        do {
            userAccountDocRef = try await collectionRef.addDocument(data: [
                "uid": dummyUserAccount.uid,
                "displayName": dummyUserAccount.displayName
            ])
            dummyUserAccount.setUserDataStoreDocumentId(userDataStoreDocumentId: userAccountDocRef.documentID)
            
            try await sut.createDefaultUserSettings(userAccount: dummyUserAccount)
        } catch {
            print(error)
        }
        
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
