//
//  UserDataStoreManager.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/18.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class UserDataStoreManager {
    static let shared = UserDataStoreManager()
    private init() {}
}

extension UserDataStoreManager {
    func createUserDataStore(user: UserAccount) async throws {
        let firestoreDB = Firestore.firestore()
        try await firestoreDB.collection("users").addDocument(data: [
            "uid": user.uid,
            "displayName": user.displayName
        ])
    }
    
    func getUserDataStoreDocumentId(user: UserAccount) async throws -> String {
        let firestoreDB = Firestore.firestore()
        guard let userDocumentId = try await firestoreDB.collection("users")
            .whereField("uid", isEqualTo: user.uid)
            .getDocuments()
            .documents.first?.documentID
        else {
            throw NetworkError.invalidData
        }
        
        return userDocumentId
    }
}
