//
//  UserSettingsManager.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/14.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

enum UserSettingsManagerError: Error {
    case userDataStoreDocumentIdDoesNotExist
    case rejectedWritingDocument
    case failedFetchingUserSettingsDocuments
    case documentDoesNotExist
    case failedInstantiateUserSettings
    case userSettingsDocumentIdDoesNotExist
    case failedUpdateDocument
}

final class UserSettingsManager {
    static let shared = UserSettingsManager()
    private init() {}
    private var userSettings: UserSettings? {
        didSet {
            if oldValue == nil && userSettings != nil {
                postNotification()
            } else if oldValue != nil && userSettings == nil {
                postNotification()
            }
        }
    }
    
    private func postNotification() {
        NotificationCenter.default.post(
            name: Notification.Name.userSettingsChanged,
            object: nil,
            userInfo: ["user_settings": userSettings as Any]
        )
    }

    private let firestoreDB = Firestore.firestore()
}

private extension UserSettingsManager {
    func getUserSettingsCollectionReference(userDataStoreDocumentId: String) -> CollectionReference {
        let userDocRef = firestoreDB.collection("users").document(userDataStoreDocumentId)
        let userSettingsCollectionRef = userDocRef.collection("user_settings")
        return userSettingsCollectionRef
    }
}

extension UserSettingsManager: UserSettingsManagerProtocol {
    var currentUserSettings: UserSettings {
        if let userSettings {
            return userSettings
        } else {
            return UserSettings.defaultSettingsWithDummyUID()
        }
    }
    
    
    /// ユーザ設定のデフォルト値を作成する
    ///
    /// - throws: UserSettingsManagerError
    ///
    /// ```
    /// # UserSettingsManagerError
    /// - userDataStoreDocumentIdDoesNotExist
    /// - rejectedWritingDocument
    /// ```
    func createDefaultUserSettings(userAccount: UserAccount) async throws {
        guard let userDataStoreDocumentId = userAccount.userDataStoreDocumentId
        else {
            throw UserSettingsManagerError.userDataStoreDocumentIdDoesNotExist
        }
        
        var defaultSettings = UserSettings.defaultSettings(uid: userAccount.uid)
        let defaultSettingsDict = defaultSettings.toDictionary()
        
        let userSettingsCollectionRef = getUserSettingsCollectionReference(
            userDataStoreDocumentId: userDataStoreDocumentId
        )
        do {
            let docRef = try await userSettingsCollectionRef.addDocument(data: defaultSettingsDict)
            defaultSettings.setSettingsDocumentId(userSettingsDocumentId: docRef.documentID)
            self.userSettings = defaultSettings
        } catch {
            throw UserSettingsManagerError.rejectedWritingDocument
        }
    }

    /// ユーザ設定を取得する
    ///
    /// - throws: UserSettingsManagerError
    ///
    /// ```
    /// # UserSettingsManagerError
    /// - userDataStoreDocumentIdDoesNotExist
    /// - failedFetchingUserSettingsDocuments
    /// - documentDoesNotExist
    /// - failedInstantiateUserSettings
    /// ```
    func fetchCurrentUserSettings(userAccount: UserAccount) async throws {
        guard let userDataStoreDocumentId = userAccount.userDataStoreDocumentId
        else {
            throw UserSettingsManagerError.userDataStoreDocumentIdDoesNotExist
        }
        
        let userSettingsCollectionRef = getUserSettingsCollectionReference(
            userDataStoreDocumentId: userDataStoreDocumentId
        )
        
        let documents: [QueryDocumentSnapshot]
        do {
            documents = try await userSettingsCollectionRef
                .whereField("uid", isEqualTo: userAccount.uid)
                .getDocuments().documents
        } catch {
            print(error)
            throw UserSettingsManagerError.failedFetchingUserSettingsDocuments
        }

        guard let snapshot = documents.first
        else {
            throw UserSettingsManagerError.documentDoesNotExist
        }
        
        guard let currentUserSettings = UserSettings.fromSnapshot(snapshot: snapshot)
        else {
            throw UserSettingsManagerError.failedInstantiateUserSettings
        }
        self.userSettings = currentUserSettings
    }
    
    /// ユーザ設定を更新する
    ///
    /// - throws: UserSettingsManagerError
    ///
    /// ```
    /// # UserSettingsManagerError
    /// - userDataStoreDocumentIdDoesNotExist
    /// - userSettingsDocumentIdDoesNotExist
    /// - failedUpdateDocument
    /// ```
    func updateUserSettings(by updatedUserSettings: UserSettings, userAccount: UserAccount) async throws {
        guard let userDataStoreDocumentId = userAccount.userDataStoreDocumentId
        else {
            throw UserSettingsManagerError.userDataStoreDocumentIdDoesNotExist
        }
        guard let userSettingsDocumentId = updatedUserSettings.userSettingsDocumentId else {
            throw UserSettingsManagerError.userSettingsDocumentIdDoesNotExist
        }
        
        let userSettingsCollectionRef = getUserSettingsCollectionReference(
            userDataStoreDocumentId: userDataStoreDocumentId
        )
        let docRef = userSettingsCollectionRef.document(userSettingsDocumentId)
        do {
            try await docRef.updateData(updatedUserSettings.toDictionary())
        } catch {
            print(error)
            throw UserSettingsManagerError.failedUpdateDocument
        }
    }
    
    func removeCurrentUserSettings() {
        self.userSettings = nil
    }
}
