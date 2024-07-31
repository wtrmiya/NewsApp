//
//  TermManager.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/13.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

enum TermManagerError: Error {
    case failedFetchingTermDocuments
    case documentDoesNotExist
    case failedInstantiateTerm
}

final class TermManager {
    static let shared = TermManager()
    private init() {}
}

extension TermManager: TermManagerProtocol {
    /// 最新の利用規約を取得する
    ///
    /// - throws: TermManagerError
    ///
    /// ```
    /// # TermManagerError
    /// - failedFetchingTermDocuments
    /// - documentDoesNotExist
    /// - failedInstantiateTerm
    /// ```
    func getLatestTerm() async throws -> Term {
        let firestoreDB = Firestore.firestore()
        let documents: [QueryDocumentSnapshot]
        do {
            documents = try await firestoreDB.collection("terms")
                .order(by: "effectiveDate", descending: true)
                .getDocuments()
                .documents
        } catch {
            throw TermManagerError.failedFetchingTermDocuments
        }
        
        guard let snapshot = documents.first
        else {
            throw TermManagerError.documentDoesNotExist
        }
        
        guard let latestTerm = Term.fromSnapshot(snapshot: snapshot)
        else {
            throw TermManagerError.failedInstantiateTerm
        }
        
        return latestTerm
    }
}
