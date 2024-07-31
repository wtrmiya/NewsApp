//
//  UserDataStoreManager.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/18.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

enum UserDataStoreManagerError: Error {
    case rejectedWritingDocument
    case failedFetchingUserDataStoreDocuments
    case documentDoesNotExist
}

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
    /// ユーザデータストアを作成する
    ///
    /// - throws: UserDataStoreManagerError
    ///
    /// ```
    /// # UserDataStoreManagerError
    /// - rejectedWritingDocument
    /// ```
    func createUserDataStore(userAccount: UserAccount) async throws {
        do {
            try await usersCollectionRef.addDocument(data: [
                "uid": userAccount.uid,
                "displayName": userAccount.displayName
            ])
        } catch {
            print(error)
            throw UserDataStoreManagerError.rejectedWritingDocument
        }
    }
    
    /// ユーザデータストアの指定ユーザのドキュメントを取得する
    ///
    /// - throws: UserDataStoreManagerError
    ///
    /// ```
    /// # UserDataStoreManagerError
    /// - failedFetchingUserDataStoreDocuments
    /// - documentDoesNotExist
    /// ```
    func getUserDataStoreDocumentId(userAccount: UserAccount) async throws -> String {
        let documents: [QueryDocumentSnapshot]
        do {
            documents = try await usersCollectionRef
            .whereField("uid", isEqualTo: userAccount.uid)
            .getDocuments()
            .documents
        } catch {
            print(error)
            throw UserDataStoreManagerError.failedFetchingUserDataStoreDocuments
        }

        guard let userDocumentId = documents.first?.documentID
        else {
            throw UserDataStoreManagerError.documentDoesNotExist
        }
        
        return userDocumentId
    }
}
