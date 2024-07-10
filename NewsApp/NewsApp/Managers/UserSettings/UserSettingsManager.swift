//
//  UserSettingsManager.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/14.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

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
    
    func createDefaultUserSettings(userAccount: UserAccount) async throws {
        guard let userDataStoreDocumentId = userAccount.userDataStoreDocumentId else { return }
        var defaultSettings = UserSettings.defaultSettings(uid: userAccount.uid)
        let defaultSettingsDict = defaultSettings.toDictionary()
        
        let userSettingsCollectionRef = getUserSettingsCollectionReference(
            userDataStoreDocumentId: userDataStoreDocumentId
        )
        let docRef = try await userSettingsCollectionRef.addDocument(data: defaultSettingsDict)
        defaultSettings.setSettingsDocumentId(userSettingsDocumentId: docRef.documentID)
        self.userSettings = defaultSettings
    }

    func fetchCurrentUserSettings(userAccount: UserAccount) async throws {
        guard let userDataStoreDocumentId = userAccount.userDataStoreDocumentId else {
            return
        }
        
        let userSettingsCollectionRef = getUserSettingsCollectionReference(
            userDataStoreDocumentId: userDataStoreDocumentId
        )
        guard let snapshot = try await userSettingsCollectionRef
            .whereField("uid", isEqualTo: userAccount.uid)
            .getDocuments().documents.first
        else {
            return
        }
        
        let currentUserSettings = UserSettings.fromSnapshot(snapshot: snapshot)
        self.userSettings = currentUserSettings
    }
    
    func updateUserSettings(by updatedUserSettings: UserSettings, userAccount: UserAccount) async throws {
        guard let userDataStoreDocumentId = userAccount.userDataStoreDocumentId else {
            return
        }
        guard let userSettingsDocumentId = updatedUserSettings.userSettingsDocumentId else {
            return
        }
        
        let userSettingsCollectionRef = getUserSettingsCollectionReference(
            userDataStoreDocumentId: userDataStoreDocumentId
        )
        let docRef = userSettingsCollectionRef.document(userSettingsDocumentId)
        try await docRef.updateData(updatedUserSettings.toDictionary())
    }
    
    func removeCurrentUserSettings() {
        self.userSettings = nil
    }
}
