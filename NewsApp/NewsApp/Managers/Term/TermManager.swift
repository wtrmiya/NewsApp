//
//  TermManager.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/13.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class TermManager {
    static let shared = TermManager()
    private init() {}
}

extension TermManager {
    func getLatestTerm() async throws -> Term? {
        let firestoreDB = Firestore.firestore()
        guard let snapshot = try await firestoreDB.collection("terms")
            .order(by: "effectiveDate", descending: true)
            .getDocuments()
            .documents.first
        else {
            return nil
        }
        
        guard let latestTerm = Term.fromSnapshot(snapshot: snapshot)
        else {
            return nil
        }

        return latestTerm
    }
}
