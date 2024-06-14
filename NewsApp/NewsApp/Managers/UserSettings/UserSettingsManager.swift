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
    
    private var currentUserSettings: UserSettings?
}

extension UserSettingsManager {
    func registerDefaultUserSettings(uid: String) async throws {
        let firestoreDB = Firestore.firestore()
        let defaultSettings = UserSettings.defaultSettings(uid: uid)
        let defaultSettingsDict = defaultSettings.toDictionary()
        try await firestoreDB.collection("user_settings").addDocument(data: defaultSettingsDict)
        self.currentUserSettings = defaultSettings
    }
    
    func getCurrentUserSettings(uid: String) async throws {
        let firestoreDB = Firestore.firestore()
        guard let snapshot = try await firestoreDB.collection("user_settings")
            .whereField("uid", isEqualTo: uid)
            .getDocuments().documents.first
        else { return }
        
        let currentUserSettings = UserSettings.fromSnapshot(snapshot: snapshot)
        return self.currentUserSettings = currentUserSettings
    }
    
    func updateUserSettings(by updatedUserSettings: UserSettings) async throws {
        let firestoreDB = Firestore.firestore()
        guard let userSettingsDocumentID = try await firestoreDB.collection("user_settings")
            .whereField("uid", isEqualTo: updatedUserSettings.uid)
            .getDocuments().documents.first?.documentID
        else { return }
        
        let docRef = firestoreDB.collection("user_settings").document(userSettingsDocumentID)
        try await docRef.updateData(updatedUserSettings.toDictionary())
    }
    
    func removeCurrentUserSettings() {
        self.currentUserSettings = nil
    }
}
