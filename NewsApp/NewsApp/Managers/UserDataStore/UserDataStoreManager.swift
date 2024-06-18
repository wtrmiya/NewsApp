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
    
    private let firestoreDB = Firestore.firestore()
}

private extension UserDataStoreManager {
    var usersCollectionRef: CollectionReference {
        return firestoreDB.collection("users")
    }
}

extension UserDataStoreManager {
    func createUserDataStore(user: UserAccount) async throws {
        try await usersCollectionRef.addDocument(data: [
            "uid": user.uid,
            "displayName": user.displayName
        ])
    }
    
    func getUserDataStoreDocumentId(user: UserAccount) async throws -> String {
        guard let userDocumentId = try await usersCollectionRef
            .whereField("uid", isEqualTo: user.uid)
            .getDocuments()
            .documents.first?.documentID
        else {
            throw NetworkError.invalidData
        }
        
        return userDocumentId
    }
}
