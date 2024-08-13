//
//  NewsAppTermManagerIntegrationTests.swift
//  NewsAppIntegrationTests
//
//  Created by Wataru Miyakoshi on 2024/08/11.
//

import XCTest
@testable import NewsApp
import FirebaseFirestore
import FirebaseFirestoreSwift

final class NewsAppTermManagerIntegrationTests: XCTestCase {
    func test_利用規約を取得する() async {
        // termsを作成する
        let firestore = Firestore.firestore()
        let termsCollectionRef = firestore.collection("terms")
        let newTerm = Term(
            title: "New Term",
            body: "It's new term body.",
            effectiveDate: Date(),
            createdAt: Date()
        )
        let termDict: [String: Any] = [
            "body": newTerm.body,
            "title": newTerm.title,
            "createdAt": newTerm.createdAt,
            "effectiveDate": newTerm.effectiveDate
        ]
        
        do {
            let _ = try await termsCollectionRef.addDocument(data: termDict)
        } catch {
            XCTFail(error.localizedDescription)
            return
        }
        
        let sut = TermManager.shared
        
        do {
            let fetchedTerm: Term = try await sut.getLatestTerm()
            
            XCTAssertEqual(fetchedTerm.title, newTerm.title)
            XCTAssertEqual(fetchedTerm.body, newTerm.body)
            /*
            XCTAssertEqual(fetchedTerm.createdAt, newTerm.createdAt)
            XCTAssertEqual(fetchedTerm.effectiveDate, newTerm.effectiveDate)
             */
        } catch {
            XCTFail(error.localizedDescription)
            return
        }
    }
}
