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

extension UserDataStoreManager: UserDataStoreManagerProtocol {
    func createUserDataStore(userAccount: UserAccount) async throws {
        try await usersCollectionRef.addDocument(data: [
            "uid": userAccount.uid,
            "displayName": userAccount.displayName
        ])
    }
    
    func getUserDataStoreDocumentId(userAccount: UserAccount) async throws -> String {
        guard let userDocumentId = try await usersCollectionRef
            .whereField("uid", isEqualTo: userAccount.uid)
            .getDocuments()
            .documents.first?.documentID
        else {
            throw NetworkError.invalidData
        }
        
        return userDocumentId
    }
}
