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
            print(userSettings.debugDescription)
        }
    }
    
    private let firestoreDB = Firestore.firestore()
}

private extension UserSettingsManager {
    func getUserSettingsCollectionReference(userDocumentId: String) -> CollectionReference {
        let userDocRef = firestoreDB.collection("users").document(userDocumentId)
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
    
    func createDefaultUserSettings(user: UserAccount) async throws {
        guard let userDocumentId = user.documentId else { return }
        var defaultSettings = UserSettings.defaultSettings(uid: user.uid)
        let defaultSettingsDict = defaultSettings.toDictionary()
        
        let userSettingsCollectionRef = getUserSettingsCollectionReference(userDocumentId: userDocumentId)
        let docRef = try await userSettingsCollectionRef.addDocument(data: defaultSettingsDict)
        defaultSettings.setDocumentId(documentId: docRef.documentID)
        self.userSettings = defaultSettings
    }

    func fetchCurrentUserSettings(user: UserAccount) async throws {
        guard let userDocumentId = user.documentId else {
            return
        }
        
        let userSettingsCollectionRef = getUserSettingsCollectionReference(userDocumentId: userDocumentId)
        guard let snapshot = try await userSettingsCollectionRef
            .whereField("uid", isEqualTo: user.uid)
            .getDocuments().documents.first
        else {
            return
        }
        
        let currentUserSettings = UserSettings.fromSnapshot(snapshot: snapshot)
        self.userSettings = currentUserSettings
    }
    
    func updateUserSettings(by updatedUserSettings: UserSettings, user: UserAccount) async throws {
        guard let userDocumentId = user.documentId else { return }
        guard let userSettingsDocumentId = updatedUserSettings.documentId else { return }
        
        let userSettingsCollectionRef = getUserSettingsCollectionReference(userDocumentId: userDocumentId)
        let docRef = userSettingsCollectionRef.document(userSettingsDocumentId)
        try await docRef.updateData(updatedUserSettings.toDictionary())
    }
    
    func removeCurrentUserSettings() {
        self.userSettings = nil
    }
}
